require "io/console"

module Generators
  module Avo
    # The `rails g avo:skills` install flow: one question per screen, answered
    # up front, then the generator runs to completion without interrupting.
    #
    # Two screen kinds. A :radio moves its selection with the arrows, so
    # down-then-enter picks the second option — pressing space to commit a
    # highlighted row is a step people miss. A :checkbox has an independent
    # state per row, so there space is the toggle and the arrows only move.
    #
    # Written against io/console from stdlib rather than a prompt gem: avo is a
    # dependency of other people's apps, and a TUI is not worth adding one for.
    class SkillsInstallPanel
      # `visible_when` takes the answers so far, so a screen that only makes
      # sense given an earlier answer is skipped rather than asked pointlessly.
      # `summary` takes them too, and renders above the options — how the final
      # confirm screen shows what it is about to do.
      Screen = Struct.new(:key, :kind, :title, :hint, :options, :visible_when, :summary)
      Option = Struct.new(:key, :label, :hint, :recommended)

      Result = Struct.new(:answers, :cancelled) do
        def cancelled? = !!cancelled

        def [](key) = answers[key]
      end

      def self.interactive?
        $stdin.tty? && $stdout.tty?
      end

      # `defaults` seeds each screen, including one that never becomes visible —
      # its default is then simply the answer.
      def initialize(screens, defaults: {}, input: $stdin, output: $stdout)
        @screens = screens
        @input = input
        @output = output
        @answers = {}
        @screens.each { |s| @answers[s.key] = defaults.fetch(s.key) { initial_for(s) } }
      end

      # `step` carries the direction, so a skipped screen is stepped over the
      # way it was entered — otherwise going back would walk into it forwards.
      def run
        index = 0
        step = 1

        while index < @screens.length
          screen = @screens[index]
          unless visible?(screen)
            index += step
            next
          end

          case ask(screen, first: first_visible?(index))
          when :back then step = -1
          when :cancel then return Result.new({}, true)
          else step = 1
          end
          index += step
        end

        Result.new(@answers, false)
      end

      private

      def visible?(screen) = screen.visible_when.nil? || screen.visible_when.call(@answers)

      # Back is only offered when there is an earlier screen still worth
      # returning to, so a hidden first screen does not strand the user.
      def first_visible?(index) = @screens[0...index].none? { visible?(_1) }

      attr_reader :input, :output

      def initial_for(screen)
        if screen.kind == :radio
          (screen.options.find(&:recommended) || screen.options.first).key
        else
          screen.options.map(&:key)
        end
      end

      def ask(screen, first:)
        cursor = start_cursor(screen)
        rows = 0

        loop do
          rows = draw(screen, cursor, rows, first: first)

          case read_key
          when :up then cursor = (cursor - 1) % screen.options.length
          when :down then cursor = (cursor + 1) % screen.options.length
          when :space then toggle(screen, cursor)
          when :enter then return commit(screen, cursor, rows)
          when :back then (return erase(rows) { :back }) unless first
          when :cancel then return erase(rows) { :cancel }
          end

          # A radio's selection follows the cursor, so moving is choosing and
          # enter alone is enough.
          @answers[screen.key] = screen.options[cursor].key if screen.kind == :radio
        end
      end

      def start_cursor(screen)
        return 0 unless screen.kind == :radio

        screen.options.index { |o| o.key == @answers[screen.key] } || 0
      end

      def toggle(screen, cursor)
        return if screen.kind == :radio

        key = screen.options[cursor].key
        selected = @answers[screen.key]
        # Refuse to empty the set: installing nowhere writes nothing and reads
        # as a silent no-op.
        return if selected == [key]

        @answers[screen.key] = selected.include?(key) ? selected - [key] : selected + [key]
        @answers[screen.key] = screen.options.map(&:key).select { |k| @answers[screen.key].include?(k) }
      end

      def commit(screen, cursor, rows)
        @answers[screen.key] = screen.options[cursor].key if screen.kind == :radio
        erase(rows) { :next }
      end

      def erase(rows)
        output.print("\e[#{rows}A\e[J") if rows.positive?
        yield
      end

      def draw(screen, cursor, previous_rows, first:)
        output.print("\e[#{previous_rows}A\e[J") if previous_rows.positive?

        lines = ["", "  #{bold(screen.title)}"]
        lines << "  #{dim(screen.hint)}" if screen.hint
        lines << ""

        if screen.summary
          screen.summary.call(@answers).each { |line| lines << "    #{line}" }
          lines << ""
        end

        screen.options.each_with_index do |option, i|
          lines << option_row(screen, option, i, cursor)
        end

        lines << ""
        lines << "  #{dim(keys_hint(screen, first: first))}"
        lines << ""

        output.print(lines.join("\n") + "\n")
        lines.length
      end

      def option_row(screen, option, index, cursor)
        marker =
          if screen.kind == :radio
            (@answers[screen.key] == option.key) ? "(•)" : "( )"
          else
            @answers[screen.key].include?(option.key) ? "[x]" : "[ ]"
          end

        label = option.label
        label += " #{dim("(recommended)")}" if option.recommended
        text = "#{(cursor == index) ? "›" : " "} #{marker} #{label}"
        text += "  #{dim(option.hint)}" if option.hint

        (cursor == index) ? "  #{bold(text)}" : "  #{text}"
      end

      def keys_hint(screen, first:)
        parts = ["↑↓ move"]
        parts << "space toggle" if screen.kind == :checkbox
        parts << "enter continue"
        parts << "← back" unless first
        parts << "q cancel"
        parts.join("   ")
      end

      def read_key
        char = input.getch
        case char
        when "\r", "\n" then :enter
        when " " then :space
        # nil is EOF: stdin closed, or a test keyboard ran dry. Treat it as
        # cancel rather than spinning on it forever.
        when nil, "q", "\u0003", "\u0004" then :cancel
        when "\e" then escape_sequence
        else :none
        end
      rescue Interrupt
        :cancel
      end

      # Arrows arrive as ESC [ A. A bare ESC cancels, so peek before deciding.
      def escape_sequence
        return :cancel unless input.respond_to?(:read_nonblock)

        begin
          seq = input.read_nonblock(2)
        rescue IO::WaitReadable, EOFError, Errno::EAGAIN, Errno::EWOULDBLOCK
          return :cancel
        end

        case seq
        when "[A" then :up
        when "[B" then :down
        when "[D" then :back
        else :none
        end
      end

      def bold(text) = "\e[1m#{text}\e[0m"

      def dim(text) = "\e[2m#{text}\e[0m"
    end
  end
end
