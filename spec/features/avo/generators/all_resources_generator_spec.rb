require "rails_helper"
require "rails/generators"
require "generators/avo/all_resources_generator"

RSpec.feature "all_resources generator", type: :feature do
  it "only discovers ActiveRecord models" do
    generator = Generators::Avo::AllResourcesGenerator.new
    models = generator.send(:fetch_models)

    expect(models).not_to include("Current")
    expect(models).not_to include("ApplicationRecord")
    expect(models).to include("Location")
    expect(models).to include("Course::Link")
  end
end
