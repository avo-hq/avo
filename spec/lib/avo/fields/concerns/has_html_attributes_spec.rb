require "rails_helper"

RSpec.describe Avo::Fields::Concerns::HasHTMLAttributes do
  let(:resource) { Avo::Resources::Course.new(record: Course.new, view: :edit) }

  def input_data(html)
    Avo::Fields::TextField.new(:name, html: html, resource: resource).get_html(:data, view: :edit, element: :input)
  end

  it "adds the resource stimulus targets to the input when the html block sets no input data" do
    data = input_data(-> { edit { wrapper { classes { "hidden" } } } })

    expect(data).to include("resource-edit-target": "nameTextInput", "city-in-country-target": "nameTextInput")
  end

  it "keeps the resource stimulus targets beside the input data the html block sets" do
    data = input_data(-> { edit { input { data { {foo: "bar"} } } } })

    expect(data).to include(foo: "bar", "resource-edit-target": "nameTextInput")
  end
end
