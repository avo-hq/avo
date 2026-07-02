require "rails_helper"

RSpec.describe "mount_avo" do
  around do |example|
    original = Avo.configuration.mount_lookbook
    example.run
  ensure
    Avo.configuration.mount_lookbook = original
  end

  def draw_mount_avo(**options)
    routes = ActionDispatch::Routing::RouteSet.new
    routes.draw { mount_avo(**options) }
    routes
  end

  it "defaults mount_lookbook to false" do
    draw_mount_avo

    expect(Avo.configuration.mount_lookbook).to be false
  end

  it "sets mount_lookbook when mount_lookbook: true is passed" do
    draw_mount_avo mount_lookbook: true

    expect(Avo.configuration.mount_lookbook).to be true
  end

  it "sets mount_lookbook to false when mount_lookbook: false is passed" do
    Avo.configuration.mount_lookbook = true

    draw_mount_avo mount_lookbook: false

    expect(Avo.configuration.mount_lookbook).to be false
  end
end

RSpec.describe Avo::Configuration, "#mount_lookbook" do
  it "defaults to false" do
    expect(described_class.new.mount_lookbook).to be false
  end
end
