require "rails_helper"

RSpec.describe Avo::Fields::Concerns::HasHTMLAttributes do
  let(:course) { Course.new }
  let(:view) { Avo::ViewInquirer.new(:edit) }
  let(:course_resource) { Avo::Resources::Course.new(record: course, view: view) }
  let(:stimulus_targets) do
    {
      "city-in-country-target": "countryBelongsToInput",
      "toggle-fields-target": "countryBelongsToInput",
      "resource-edit-target": "countryBelongsToInput"
    }
  end

  def input_data_for(html)
    Avo::Fields::BelongsToField.new(:country, html: html)
      .hydrate(record: course, resource: course_resource, view: view)
      .get_html(:data, view: :edit, element: :input)
  end

  it "adds the resource stimulus targets when there is no html option" do
    expect(input_data_for(nil)).to include(stimulus_targets)
  end

  it "adds the resource stimulus targets when the html block only styles the wrapper" do
    html = -> do
      edit do
        wrapper do
          classes { "hidden" }
        end
      end
    end

    expect(input_data_for(html)).to include(stimulus_targets)
  end

  it "adds the resource stimulus targets next to the input data from the html block" do
    html = -> do
      edit do
        input do
          data({foo: "bar"})
        end
      end
    end

    expect(input_data_for(html)).to include(stimulus_targets.merge(foo: "bar"))
  end
end
