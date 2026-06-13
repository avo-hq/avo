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
end
