require "rails_helper"
require "stringio"
require "generators/avo/skills_install_panel"

# Drives the panel through a fake keyboard. Scope is a radio and targets are
# checkboxes, so the interesting cases are the ones where those two behaviors
# differ.
# `getch` reads one character; arrow keys arrive as ESC then "[A"/"[B", which
# the panel reads with a follow-up read_nonblock.
class FakeKeyboard
  KEYS = {up: ["\e", "[A"], down: ["\e", "[B"], space: [" "], enter: ["\r"], cancel: ["q"]}.freeze

  def initialize(keys)
    @chars = keys.flat_map { KEYS.fetch(_1) }
  end

  def getch = @chars.shift

  def read_nonblock(_n) = @chars.shift
end

RSpec.describe Generators::Avo::SkillsInstallPanel do
  def run(*keys)
    described_class.new(input: FakeKeyboard.new(keys), output: StringIO.new).run
  end

  it "defaults to this app with every agent selected" do
    result = run(:enter)

    expect(result.scope).to eq "local"
    expect(result.targets).to eq %w[claude agents cursor]
    expect(result).not_to be_cancelled
  end

  it "selects the global scope" do
    result = run(:down, :space, :enter)

    expect(result.scope).to eq "global"
  end

  # Radio, not checkbox: choosing one scope must clear the other.
  it "keeps the scope exclusive" do
    result = run(:down, :space, :up, :space, :enter)

    expect(result.scope).to eq "local"
  end

  it "toggles an agent off without touching the others" do
    result = run(:down, :down, :space, :enter)   # rows: 0 app, 1 machine, 2 .claude

    expect(result.targets).to eq %w[agents cursor]
    expect(result.scope).to eq "local"
  end

  it "toggles an agent back on" do
    result = run(:down, :down, :space, :space, :enter)

    expect(result.targets).to eq %w[claude agents cursor]
  end

  # An install with no target writes nothing and reads as a silent no-op, so
  # the last selected agent refuses to turn off.
  it "refuses to leave zero agents selected" do
    result = run(:down, :down, :space, :down, :space, :down, :space, :enter)

    expect(result.targets.length).to eq 1
  end

  it "wraps the cursor from the last row to the first" do
    result = run(:up, :space, :enter)

    expect(result.targets).to eq %w[claude agents]
  end

  it "cancels on q without choosing anything" do
    result = run(:cancel)

    expect(result).to be_cancelled
    expect(result.targets).to be_empty
  end

  describe "rendering" do
    it "shows both groups, the keybindings, and the current selection" do
      output = StringIO.new
      described_class.new(input: FakeKeyboard.new([:enter]), output: output).run
      plain = output.string.gsub(/\e\[[0-9;]*[A-Za-z]/, "")

      expect(plain).to include("Install the Avo skills loader")
      expect(plain).to include("This app", "This machine")
      expect(plain).to include(".claude/skills", ".agents/skills", ".cursor/skills")
      expect(plain).to include("space select", "enter install", "q cancel")
      expect(plain).to include("(•)")
      expect(plain).to include("[x]")
    end
  end

  describe ".interactive?" do
    it "is false when stdin is not a tty, so CI and piped runs skip the panel" do
      allow($stdin).to receive(:tty?).and_return(false)

      expect(described_class).not_to be_interactive
    end
  end
end
