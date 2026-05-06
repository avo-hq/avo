require "rails_helper"
require "rails/generators"

RSpec.feature "namespaced resource generator", type: :feature, acquire_lock: :generator do
  it "infers the namespaced ActiveRecord model for field generation (not singular_name)" do
    files = [
      Rails.root.join("app", "avo", "resources", "galaxy", "planet.rb").to_s,
      Rails.root.join("app", "controllers", "avo", "galaxy", "planets_controller.rb").to_s
    ]

    Rails::Generators.invoke("avo:resource", ["Galaxy::Planet", "--quiet", "--skip"], {destination_root: Rails.root})

    resource_content = File.read(files[0])
    expect(resource_content).to include("field :name")
    expect(resource_content).not_to include("Can't generate fields from model")
    expect(resource_content).not_to include("self.model_class =")
  ensure
    files.each { |f| FileUtils.rm_f(f) }
    FileUtils.rm_rf(Rails.root.join("app", "avo", "resources", "galaxy"))
    FileUtils.rm_rf(Rails.root.join("app", "controllers", "avo", "galaxy"))
  end

  it "generates a namespaced resource and controller at the correct paths" do
    files = [
      Rails.root.join("app", "avo", "resources", "billing", "invoice.rb").to_s,
      Rails.root.join("app", "controllers", "avo", "billing", "invoices_controller.rb").to_s
    ]

    Rails::Generators.invoke("avo:resource", ["Billing::Invoice", "--quiet", "--skip"], {destination_root: Rails.root})

    expect(File.exist?(files[0])).to be true
    expect(File.exist?(files[1])).to be true

    resource_content = File.read(files[0])
    expect(resource_content).to include("class Avo::Resources::Billing::Invoice < Avo::BaseResource")
    expect(resource_content).not_to include("self.model_class =")

    controller_content = File.read(files[1])
    expect(controller_content).to include("class Avo::Billing::InvoicesController <")
  ensure
    files.each { |f| FileUtils.rm_f(f) }
    FileUtils.rm_rf(Rails.root.join("app", "avo", "resources", "billing"))
    FileUtils.rm_rf(Rails.root.join("app", "controllers", "avo", "billing"))
  end

  it "still generates flat resources at the original paths" do
    files = [
      Rails.root.join("app", "avo", "resources", "wombat.rb").to_s,
      Rails.root.join("app", "controllers", "avo", "wombats_controller.rb").to_s
    ]

    Rails::Generators.invoke("avo:resource", ["wombat", "--quiet", "--skip"], {destination_root: Rails.root})

    expect(File.exist?(files[0])).to be true
    expect(File.exist?(files[1])).to be true

    expect(File.read(files[0])).to include("class Avo::Resources::Wombat < Avo::BaseResource")
    expect(File.read(files[1])).to include("class Avo::WombatsController <")
  ensure
    files.each { |f| FileUtils.rm_f(f) }
  end

  it "injects self.model_class only when --model-class is explicitly provided" do
    files = [
      Rails.root.join("app", "avo", "resources", "shop", "item.rb").to_s,
      Rails.root.join("app", "controllers", "avo", "shop", "items_controller.rb").to_s
    ]

    Rails::Generators.invoke(
      "avo:resource",
      ["Shop::Item", "--model-class", "Shop::Product", "--quiet", "--skip"],
      {destination_root: Rails.root}
    )

    expect(File.read(files[0])).to include("self.model_class = ::Shop::Product")
  ensure
    files.each { |f| FileUtils.rm_f(f) }
    FileUtils.rm_rf(Rails.root.join("app", "avo", "resources", "shop"))
    FileUtils.rm_rf(Rails.root.join("app", "controllers", "avo", "shop"))
  end

  it "generates a 3-level namespaced resource and controller" do
    files = [
      Rails.root.join("app", "avo", "resources", "universe", "cluster", "star.rb").to_s,
      Rails.root.join("app", "controllers", "avo", "universe", "cluster", "stars_controller.rb").to_s
    ]

    Rails::Generators.invoke("avo:resource", ["Universe::Cluster::Star", "--quiet", "--skip"], {destination_root: Rails.root})

    expect(File.exist?(files[0])).to be true
    expect(File.exist?(files[1])).to be true

    expect(File.read(files[0])).to include("class Avo::Resources::Universe::Cluster::Star < Avo::BaseResource")
    expect(File.read(files[1])).to include("class Avo::Universe::Cluster::StarsController <")
  ensure
    files.each { |f| FileUtils.rm_f(f) }
    FileUtils.rm_rf(Rails.root.join("app", "avo", "resources", "universe"))
    FileUtils.rm_rf(Rails.root.join("app", "controllers", "avo", "universe"))
  end

  it "generates a 4-level namespaced resource and controller" do
    files = [
      Rails.root.join("app", "avo", "resources", "universe", "cluster", "star", "comet.rb").to_s,
      Rails.root.join("app", "controllers", "avo", "universe", "cluster", "star", "comets_controller.rb").to_s
    ]

    Rails::Generators.invoke("avo:resource", ["Universe::Cluster::Star::Comet", "--quiet", "--skip"], {destination_root: Rails.root})

    expect(File.exist?(files[0])).to be true
    expect(File.exist?(files[1])).to be true

    expect(File.read(files[0])).to include("class Avo::Resources::Universe::Cluster::Star::Comet < Avo::BaseResource")
    expect(File.read(files[1])).to include("class Avo::Universe::Cluster::Star::CometsController <")
  ensure
    files.each { |f| FileUtils.rm_f(f) }
    FileUtils.rm_rf(Rails.root.join("app", "avo", "resources", "universe"))
    FileUtils.rm_rf(Rails.root.join("app", "controllers", "avo", "universe"))
  end
end
