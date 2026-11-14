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

  describe "the attributes key" do
    def html_attributes(html, view: :edit, element: :input)
      Avo::Fields::TextField.new(:name, html: html, resource: resource).get_html(:attributes, view: view, element: element)
    end

    it "is an empty Hash when the field has no html option" do
      expect(html_attributes(nil)).to eq({})
    end

    it "is an empty Hash when the html option sets no attributes for the element" do
      expect(html_attributes({edit: {input: {classes: "w-1/2"}}})).to eq({})
      expect(html_attributes(-> { edit { input { classes "w-1/2" } } })).to eq({})
    end

    it "reads the attributes from the object notation" do
      html = {edit: {input: {attributes: {autocapitalize: "characters", maxlength: 3}}}}

      expect(html_attributes(html)).to eq(autocapitalize: "characters", maxlength: 3)
    end

    it "reads the attributes from the block notation as a payload or a block" do
      expect(html_attributes(-> { edit { input { attributes(autocapitalize: "characters") } } })).to eq(autocapitalize: "characters")
      expect(html_attributes(-> { edit { input { attributes { {maxlength: 6} } } } })).to eq(maxlength: 6)
    end

    it "merges the attributes declared at every level of the block notation" do
      html = -> do
        attributes(title: "Everywhere")
        input { attributes(inputmode: "numeric") }
        edit { input { attributes(maxlength: 6) } }
      end

      expect(html_attributes(html)).to eq(title: "Everywhere", inputmode: "numeric", maxlength: 6)
    end

    it "keeps the attributes of one view and element to that view and element" do
      html = {show: {content: {attributes: {title: "Shown"}}}, edit: {wrapper: {attributes: {title: "Wrapped"}}}}

      expect(html_attributes(html, view: :show, element: :content)).to eq(title: "Shown")
      expect(html_attributes(html, view: :edit, element: :wrapper)).to eq(title: "Wrapped")
      expect(html_attributes(html, view: :edit, element: :input)).to eq({})
    end

    it "symbolizes the keys so the element's own attributes replace them instead of rendering twice" do
      expect(html_attributes({edit: {input: {attributes: {"aria-describedby" => "hint"}}}})).to eq("aria-describedby": "hint")
    end

    it "drops class, style and data, which come from their own keys" do
      html = {edit: {input: {attributes: {"class" => "x", :style => "color: red;", :data => {foo: "bar"}, :spellcheck => false}}}}

      expect(html_attributes(html)).to eq(spellcheck: false)
    end

    it "ignores attributes that aren't a Hash" do
      expect(html_attributes({edit: {input: {attributes: "required"}}})).to eq({})
      expect(html_attributes(-> { edit { input { attributes "required" } } })).to eq({})
    end
  end
end
