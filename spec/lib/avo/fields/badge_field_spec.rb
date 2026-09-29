require "rails_helper"

RSpec.describe Avo::Fields::BadgeField do
  def form_visibility(field)
    [:new, :edit].map { |view| field.visible_in_view?(view:) }
  end

  it "stays off the forms by default" do
    expect(form_visibility(described_class.new(:stage))).to eq [false, false]
  end

  it "shows on the forms when editable" do
    expect(form_visibility(described_class.new(:stage, editable: true))).to eq [true, true]
  end

  it "keeps a computed badge off the forms, since there is no attribute to save" do
    field = described_class.new(:stage, editable: true) { "Done" }

    expect(form_visibility(field)).to eq [false, false]
  end
end
