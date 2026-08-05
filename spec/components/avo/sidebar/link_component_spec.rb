require "rails_helper"

RSpec.describe Avo::Sidebar::LinkComponent, type: :component do
  describe "#is_external?" do
    def build(path:, mount_path: "/avo", prefix_path: nil)
      root_path = "#{prefix_path}#{mount_path}"
      component = described_class.new(label: "Link", path: path)
      allow(component).to receive(:helpers).and_return(
        double(mount_path: mount_path, root_path_without_url: root_path)
      )
      component
    end

    it "treats relative app paths as internal" do
      expect(build(path: "/avo/resources/users").is_external?).to be false
    end

    it "treats full URLs mounted under Avo as internal" do
      expect(build(path: "https://demo.example.com/avo/resources/users").is_external?).to be false
    end

    it "treats full URLs with a prefix_path as internal" do
      path = "https://demo.example.com/internal/avo/resources/users"
      expect(
        build(path: path, mount_path: "/avo", prefix_path: "/internal").is_external?
      ).to be false
    end

    it "treats external hosts as external" do
      expect(build(path: "https://google.com").is_external?).to be true
    end

    # Regression: "avohq.io" contains the substring "/avo" (via "//avohq.io"), which a
    # naive String#include?(mount_path) check misclassified as an internal Avo link.
    it "does not misclassify hosts whose name starts with the mount path" do
      expect(build(path: "https://avohq.io").is_external?).to be true
    end

    it "returns true for invalid URIs" do
      expect(build(path: "http://[invalid").is_external?).to be true
    end
  end

  describe "#resolved_active" do
    def build(path:, active: :inclusive)
      component = described_class.new(label: "Link", path: path, active: active)
      allow(component).to receive(:helpers).and_return(double(root_path_without_url: "/avo"))
      component
    end

    it "downgrades a default root link to :exclusive so it isn't active everywhere" do
      expect(build(path: "/avo").resolved_active).to eq :exclusive
      expect(build(path: "/avo/").resolved_active).to eq :exclusive
    end

    it "leaves non-root links inclusive" do
      expect(build(path: "/avo/resources/users").resolved_active).to eq :inclusive
    end

    it "only overrides the default :inclusive mode, leaving other modes untouched" do
      expect(build(path: "/avo", active: :exact).resolved_active).to eq :exact
      expect(build(path: "/avo", active: true).resolved_active).to eq true
    end
  end

  # Unit 4 / R12: label truncation itself is measured in the browser
  # (spec/system/avo/group_1/sidebar_spec.rb), which also covers the label
  # wrapper, `title` and hotkey badge on a real (internal) resource link. This
  # renders an external link — the one shape the dummy sidebar never produces —
  # to lock the trailing badge / external-icon markup that must sit after the
  # label without shrinking.
  describe "rendering an external link" do
    let(:long_label) { "Extraordinarily Long Navigation Label That Overflows The Sidebar Width" }

    before do
      # `is_external?` / `root_link?` consult the Avo mount path via
      # `helpers.root_path_without_url`, which the component-test view context
      # doesn't expose. Stub these real methods so rendering focuses on markup.
      allow_any_instance_of(described_class).to receive(:is_external?).and_return(true)
      allow_any_instance_of(described_class).to receive(:root_link?).and_return(false)
    end

    it "wraps the label, sets an unconditional `title`, and trails badge + icon" do
      render_inline(
        described_class.new(label: long_label, path: "https://example.com/docs", target: :_blank, hotkey: "r u")
      )

      label = page.find("a.sidebar-link .sidebar-link__label")
      expect(label.text).to eq(long_label)
      expect(label[:title]).to eq(long_label)

      # `flex-1` on the label makes `ms-auto` a no-op under a long label; `shrink-0`
      # keeps the badge from being squashed.
      expect(page).to have_css("a.sidebar-link .hotkey-badge.ms-auto.shrink-0")

      # General sibling combinator: both the badge and the external icon follow
      # the label in document order.
      expect(page).to have_css("a.sidebar-link .sidebar-link__label ~ .hotkey-badge")
      expect(page).to have_css("a.sidebar-link .sidebar-link__label ~ .sidebar-link__external-icon")
    end
  end
end
