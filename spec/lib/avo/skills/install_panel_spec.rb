require "rails_helper"
require "stringio"
require "generators/avo/skills_install_panel"

# `getch` reads one character; arrows arrive as ESC then "[A"/"[B"/"[D", which
# the panel reads with a follow-up read_nonblock.
class FakeKeyboard
  KEYS = {
    up: ["\e", "[A"], down: ["\e", "[B"], back: ["\e", "[D"],
    space: [" "], enter: ["\r"], cancel: ["q"]
  }.freeze

  def initialize(keys)
    @chars = keys.flat_map { KEYS.fetch(_1) }
  end

  def getch = @chars.shift

  def read_nonblock(_n) = @chars.shift
end

RSpec.describe Generators::Avo::SkillsInstallPanel do
  def radio(key = :where)
    described_class::Screen.new(key: key, kind: :radio, title: "Where?", hint: nil, options: [
      described_class::Option.new(key: "app", label: "This app", recommended: true),
      described_class::Option.new(key: "machine", label: "This machine")
    ])
  end

  def checkbox(key = :agents)
    described_class::Screen.new(key: key, kind: :checkbox, title: "Which agents?", hint: nil, options: [
      described_class::Option.new(key: "agents", label: ".agents/skills"),
      described_class::Option.new(key: "claude", label: ".claude/skills"),
      described_class::Option.new(key: "cursor", label: ".cursor/skills")
    ])
  end

  def run(screens, keys, defaults: {})
    list = screens.is_a?(Array) ? screens : [screens]
    described_class.new(list, defaults: defaults, input: FakeKeyboard.new(keys), output: StringIO.new).run
  end

  describe "a radio screen" do
    # The bug from the review: Adrian pressed down, then enter, and it kept the
    # first option. Moving must *be* choosing.
    it "selects with down then enter, no space" do
      expect(run(radio, [:down, :enter])[:where]).to eq "machine"
    end

    it "still selects with space, for anyone who reaches for it" do
      expect(run(radio, [:down, :space, :enter])[:where]).to eq "machine"
    end

    it "defaults to the recommended option" do
      expect(run(radio, [:enter])[:where]).to eq "app"
    end

    it "wraps around" do
      expect(run(radio, [:up, :enter])[:where]).to eq "machine"
    end
  end

  describe "a checkbox screen" do
    it "starts with everything selected and space toggles one off" do
      expect(run(checkbox, [:down, :space, :enter])[:agents]).to eq %w[agents cursor]
    end

    # Re-selecting must put it back in declared position, not append it, so the
    # canonical directory stays first and gets the real file.
    it "keeps the declared order when something is toggled off and back on" do
      answer = run(checkbox, [:space, :space, :enter])

      expect(answer[:agents]).to eq %w[agents claude cursor]
    end

    it "puts a re-selected middle option back in the middle" do
      answer = run(checkbox, [:down, :space, :space, :enter])

      expect(answer[:agents]).to eq %w[agents claude cursor]
    end

    # Installing nowhere writes nothing and reads as a silent no-op.
    it "refuses to leave nothing selected" do
      expect(run(checkbox, [:space, :down, :space, :down, :space, :enter])[:agents].length).to eq 1
    end
  end

  describe "moving between screens" do
    it "answers each screen in turn" do
      answer = run([radio, checkbox], [:down, :enter, :down, :space, :enter])

      expect(answer[:where]).to eq "machine"
      expect(answer[:agents]).to eq %w[agents cursor]
    end

    # Paul's note: with everything on one screen there was no way back once you
    # had moved past a group.
    it "goes back to a previous screen and keeps what was answered there" do
      answer = run([radio, checkbox], [:down, :enter, :back, :enter, :enter])

      expect(answer[:where]).to eq "machine"
    end

    it "lets a re-answered screen change the result" do
      answer = run([radio, checkbox], [:down, :enter, :back, :up, :enter, :enter])

      expect(answer[:where]).to eq "app"
    end

    it "has no back on the first screen, so q there cancels" do
      expect(run([radio, checkbox], [:back])).to be_cancelled
    end

    it "cancels from a later screen too" do
      expect(run([radio, checkbox], [:down, :enter, :cancel])).to be_cancelled
    end
  end

  # A question that does not apply given an earlier answer should not be asked
  # at all — the alternative is a screen whose answer changes nothing.
  describe "a screen that only sometimes applies" do
    def conditional(visible_when)
      described_class::Screen.new(key: :link, kind: :radio, title: "Link them?", hint: nil, visible_when: visible_when, options: [
        described_class::Option.new(key: true, label: "Yes", recommended: true),
        described_class::Option.new(key: false, label: "No")
      ])
    end

    it "is skipped when its condition is false" do
      screens = [radio, conditional(->(a) { a[:where] == "machine" })]
      out = StringIO.new
      described_class.new(screens, input: FakeKeyboard.new([:enter]), output: out).run

      expect(out.string).not_to include "Link them?"
    end

    it "is asked when its condition is true" do
      screens = [radio, conditional(->(a) { a[:where] == "app" })]
      out = StringIO.new
      described_class.new(screens, input: FakeKeyboard.new([:enter, :enter]), output: out).run

      expect(out.string).to include "Link them?"
    end

    # Its default stands in for the answer, so downstream code never sees a nil
    # for a question that was never put.
    it "keeps its default as the answer when skipped" do
      screens = [radio, conditional(->(_a) { false })]

      answer = described_class.new(screens, input: FakeKeyboard.new([:enter]), output: StringIO.new).run

      expect(answer[:link]).to be true
    end

    # Stepping backwards has to step *over* it the same way, or back would walk
    # into the skipped screen forwards and hang there.
    it "is stepped over going back, not walked into" do
      screens = [radio, conditional(->(_a) { false }), checkbox]

      answer = described_class.new(screens, input: FakeKeyboard.new([:enter, :back, :down, :enter, :enter]), output: StringIO.new).run

      expect(answer[:where]).to eq "machine"
    end
  end

  describe "a summary" do
    def confirm(summary)
      described_class::Screen.new(key: :confirm, kind: :radio, title: "Run it?", hint: nil, summary: summary, options: [
        described_class::Option.new(key: true, label: "Yes", recommended: true),
        described_class::Option.new(key: false, label: "No")
      ])
    end

    it "renders above the options" do
      out = StringIO.new
      described_class.new([confirm(->(_a) { ["Install to    this app"] })], input: FakeKeyboard.new([:enter]), output: out).run
      plain = out.string.gsub(/\e\[[0-9;]*[A-Za-z]/, "")

      expect(plain.index("Install to    this app")).to be < plain.index("Yes")
    end

    # Built from the answers when the screen is drawn, so it shows what was
    # actually chosen rather than what was proposed.
    it "reads the answers given on earlier screens" do
      screens = [radio, confirm(->(a) { ["chose: #{a[:where]}"] })]
      out = StringIO.new
      described_class.new(screens, input: FakeKeyboard.new([:down, :enter, :enter]), output: out).run

      expect(out.string).to include "chose: machine"
    end
  end

  describe "defaults" do
    it "seeds a screen so a flag pre-selects it" do
      expect(run(radio, [:enter], defaults: {where: "machine"})[:where]).to eq "machine"
    end

    it "puts the cursor on the seeded option, so enter keeps it" do
      expect(run(radio, [:enter], defaults: {where: "machine"})[:where]).to eq "machine"
    end
  end

  describe "rendering" do
    it "marks the recommended option and shows the keys for the screen kind" do
      out = StringIO.new
      described_class.new([checkbox], input: FakeKeyboard.new([:enter]), output: out).run
      plain = out.string.gsub(/\e\[[0-9;]*[A-Za-z]/, "")

      expect(plain).to include("Which agents?", "[x] .agents/skills")
      expect(plain).to include("space toggle")
    end

    it "omits the space hint on a radio, where space is not needed" do
      out = StringIO.new
      described_class.new([radio], input: FakeKeyboard.new([:enter]), output: out).run
      plain = out.string.gsub(/\e\[[0-9;]*[A-Za-z]/, "")

      expect(plain).to include("(recommended)")
      expect(plain).not_to include("space toggle")
    end

    it "offers back only once there is somewhere to go" do
      out = StringIO.new
      described_class.new([radio, checkbox], input: FakeKeyboard.new([:enter, :enter]), output: out).run
      frames = out.string.split("\e[J")

      expect(frames.first).not_to include("back")
      expect(frames.last).to include("back")
    end
  end
end
