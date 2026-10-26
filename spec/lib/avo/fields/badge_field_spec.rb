require "rails_helper"

RSpec.describe Avo::Fields::BadgeField do
  def form_visibility(field)
    [:new, :edit].map { |view| field.visible_in_view?(view:) }
  end

  it "stays off the forms by default" do
    expect(form_visibility(described_class.new(:stage))).to eq [false, false]
  end

  it "follows the visibility options passed to the field" do
    expect(form_visibility(described_class.new(:stage, only_on: :edit))).to eq [false, true]
  end
end
