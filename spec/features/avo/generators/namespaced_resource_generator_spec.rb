require "rails_helper"
require "rails/generators"

RSpec.feature "namespaced resource generator", type: :feature, acquire_lock: :generator do
  # The dummy app commits Galaxy::Planet files, so generating into Rails.root would
  # read those instead of the output and cleaning up would delete them.
  around do |example|
    Dir.mktmpdir("namespaced-resource") do |dir|
      @destination_root = Pathname.new(dir)
      example.run
    end
  end

  it "infers the namespaced ActiveRecord model for field generation (not singular_name)" do
    resource_path = @destination_root.join("app", "avo", "resources", "galaxy", "planet.rb")

    Rails::Generators.invoke("avo:resource", ["Galaxy::Planet", "--quiet"], {destination_root: @destination_root})

    resource_content = File.read(resource_path)
    expect(resource_content).to include("field :name")
    expect(resource_content).not_to include("Can't generate fields from model")
    expect(resource_content).not_to include("self.model_class =")
  end

  it "generates a namespaced resource and controller at the correct paths" do
    files = [
      @destination_root.join("app", "avo", "resources", "billing", "invoice.rb").to_s,
      @destination_root.join("app", "controllers", "avo", "billing", "invoices_controller.rb").to_s
    ]

    Rails::Generators.invoke("avo:resource", ["Billing::Invoice", "--quiet"], {destination_root: @destination_root})

    expect(File.exist?(files[0])).to be true
    expect(File.exist?(files[1])).to be true

    resource_content = File.read(files[0])
    expect(resource_content).to include("class Avo::Resources::Billing::Invoice < Avo::BaseResource")
    expect(resource_content).not_to include("self.model_class =")

    controller_content = File.read(files[1])
    expect(controller_content).to include("class Avo::Billing::InvoicesController <")
  end

  it "still generates flat resources at the original paths" do
    files = [
      @destination_root.join("app", "avo", "resources", "wombat.rb").to_s,
      @destination_root.join("app", "controllers", "avo", "wombats_controller.rb").to_s
    ]

    Rails::Generators.invoke("avo:resource", ["wombat", "--quiet"], {destination_root: @destination_root})

    expect(File.exist?(files[0])).to be true
    expect(File.exist?(files[1])).to be true

    expect(File.read(files[0])).to include("class Avo::Resources::Wombat < Avo::BaseResource")
    expect(File.read(files[1])).to include("class Avo::WombatsController <")
  end

  it "injects self.model_class only when --model-class is explicitly provided" do
    resource_path = @destination_root.join("app", "avo", "resources", "shop", "item.rb")

    Rails::Generators.invoke(
      "avo:resource",
      ["Shop::Item", "--model-class", "Shop::Product", "--quiet"],
      {destination_root: @destination_root}
    )

    expect(File.read(resource_path)).to include("self.model_class = ::Shop::Product")
  end

  it "generates a 3-level namespaced resource and controller" do
    files = [
      @destination_root.join("app", "avo", "resources", "universe", "cluster", "star.rb").to_s,
      @destination_root.join("app", "controllers", "avo", "universe", "cluster", "stars_controller.rb").to_s
    ]

    Rails::Generators.invoke("avo:resource", ["Universe::Cluster::Star", "--quiet"], {destination_root: @destination_root})

    expect(File.exist?(files[0])).to be true
    expect(File.exist?(files[1])).to be true

    expect(File.read(files[0])).to include("class Avo::Resources::Universe::Cluster::Star < Avo::BaseResource")
    expect(File.read(files[1])).to include("class Avo::Universe::Cluster::StarsController <")
  end

  it "generates a 4-level namespaced resource and controller" do
    files = [
      @destination_root.join("app", "avo", "resources", "universe", "cluster", "star", "comet.rb").to_s,
      @destination_root.join("app", "controllers", "avo", "universe", "cluster", "star", "comets_controller.rb").to_s
    ]

    Rails::Generators.invoke("avo:resource", ["Universe::Cluster::Star::Comet", "--quiet"], {destination_root: @destination_root})

    expect(File.exist?(files[0])).to be true
    expect(File.exist?(files[1])).to be true

    expect(File.read(files[0])).to include("class Avo::Resources::Universe::Cluster::Star::Comet < Avo::BaseResource")
    expect(File.read(files[1])).to include("class Avo::Universe::Cluster::Star::CometsController <")
  end
end
