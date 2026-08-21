require "rails_helper"

RSpec.describe "RevealField", type: :system do
  let(:secret) { "super-secret-token" }
  let!(:product) { create :product, description: secret }

  before do
    Avo::Resources::Product.with_temporary_items do
      field :id, as: :id
      field :description, as: :reveal
    end
  end

  after do
    Avo::Resources::Product.restore_items_from_backup
  end

  it "toggles the masked value on reveal and hide" do
    visit avo.resources_product_path(product)

    wrapper = find("[data-field-id='description'] [data-controller='reveal-field']")
    input = wrapper.find("[data-reveal-field-target='input']")
    button = wrapper.find("[data-action='reveal-field#toggle']")

    expect(input[:type]).to eq("password")
    expect(input.value).not_to eq(secret)

    button.click

    expect(input[:type]).to eq("text")
    expect(input.value).to eq(secret)
    expect(button["aria-pressed"]).to eq("true")

    button.click

    expect(input[:type]).to eq("password")
    expect(input.value).not_to eq(secret)
    expect(button["aria-pressed"]).to eq("false")
  end
end
