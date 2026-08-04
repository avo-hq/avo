require "io/console"

module Generators
  module Avo
    # A small keyboard-driven panel for `rails g avo:skills`.
    #
    # Two groups with different semantics: scope is a radio (this app OR the
    # machine), targets are checkboxes (any combination of scan directories).
    # Written against io/console from stdlib rather than a prompt gem, because
    # avo is a dependency of other people's apps and a TUI is not worth adding
    # one for.
    #
    # Falls back to defaults whenever there is no interactive terminal, so
    # `-q`, CI, and piped invocations behave predictably. Callers pass explicit
    # flags to skip the panel entirely.
    class SkillsInstallPanel
      SCOPES = [
        {key: "local", label: "This app", hint: "committed, so the whole team gets it"},
        {key: "global", label: "This machine", hint: "one install, every Avo project"}
      ].freeze

      TARGETS = [
        {key: "claude", label: ".claude/skills", hint: "Claude Code"},
        {key: "agents", label: ".agents/skills", hint: "Codex, Gemini CLI, Goose, Amp, OpenCode"},
        {key: "cursor", label: ".cursor/skills", hint: "Cursor"}
      ].freeze

      Result = Struct.new(:scope, :targets, :cancelled) do
        def cancelled? = !!cancelled
      end

      def self.interactive?
        $stdin.tty? && $stdout.tty?
      end

      def initialize(input: $stdin, output: $stdout)
        @input = input
        @output = output
        @scope = 0
        @targets = TARGETS.map { |t| [t[:key], true] }.to_h
        @cursor = 0
        @rows_drawn = 0
      end

      # Rows are the two scopes then the three targets, so one cursor walks
      # both groups and the whole panel is arrow-navigable.
      def rows
        SCOPES.length + TARGETS.length
      end

      def run
        render
        loop do
          case read_key
          when :up then move(-1)
          when :down then move(1)
          when :space then toggle
          when :enter then return finish
          when :cancel then return cancel
          end
          render
        end
      end

      private

      attr_reader :input, :output

      def move(delta)
        @cursor = (@cursor + delta) % rows
      end

      def toggle
        if @cursor < SCOPES.length
          @scope = @cursor
        else
          key = TARGETS[@cursor - SCOPES.length][:key]
          # Refuse to empty the set: an install with no target writes nothing
          # and looks like a silent no-op.
          @targets[key] = !@targets[key] unless @targets[key] && selected_targets.length == 1
        end
      end

      def selected_targets
        TARGETS.map { |t| t[:key] }.select { |k| @targets[k] }
      end

      def finish
        clear
        Result.new(SCOPES[@scope][:key], selected_targets, false)
      end

      def cancel
        clear
        Result.new(nil, [], true)
      end

      def read_key
        char = input.getch
        case char
        when "\r", "\n" then :enter
        when " " then :space
        when "", "q", "\e" then escape_or_cancel(char)
        else :none
        end
      rescue Interrupt
        :cancel
      end

      # An arrow key arrives as ESC [ A. A bare ESC means cancel, so peek at
      # what follows before deciding.
      def escape_or_cancel(char)
        return :cancel unless char == "\e"
        return :cancel unless input.respond_to?(:read_nonblock)

        begin
          seq = input.read_nonblock(2)
        rescue IO::WaitReadable, EOFError, Errno::EAGAIN
          return :cancel
        end

        case seq
        when "[A" then :up
        when "[B" then :down
        else :none
        end
      end

      def clear
        output.print("\e[#{@rows_drawn}A\e[J") if @rows_drawn.positive?
        @rows_drawn = 0
      end

      def render
        clear
        lines = []
        lines << ""
        lines << "  Install the Avo skills loader"
        lines << ""
        lines << "  #{dim("Where")}"
        SCOPES.each_with_index do |scope, i|
          lines << row(i, (@scope == i) ? "(•)" : "( )", scope[:label], scope[:hint])
        end
        lines << ""
        lines << "  #{dim("Which agents")}"
        TARGETS.each_with_index do |target, i|
          lines << row(SCOPES.length + i, @targets[target[:key]] ? "[x]" : "[ ]", target[:label], target[:hint])
        end
        lines << ""
        lines << "  #{dim("↑↓ move   space select   enter install   q cancel")}"
        lines << ""

        output.print(lines.join("\n") + "\n")
        @rows_drawn = lines.length
      end

      def row(index, marker, label, hint)
        active = @cursor == index
        pointer = active ? "›" : " "
        text = "#{pointer} #{marker} #{label.ljust(16)} #{dim(hint)}"
        active ? "  \e[1m#{text}\e[0m" : "  #{text}"
      end

      def dim(text)
        "\e[2m#{text}\e[0m"
      end
    end
  end
end
