require "rails_helper"

RSpec.describe "RevealField", type: :feature do
  let(:secret) { "super-secret-token" }
  let(:encoded) { Base64.strict_encode64(secret) }

  before do
    Avo::Resources::Product.with_temporary_items do
      field :id, as: :id
      field :title, as: :text, only_on: :forms
      field :description, as: :reveal
    end
  end

  after do
    Avo::Resources::Product.restore_items_from_backup
  end

  describe "without a value" do
    let!(:product) { create :product, description: nil }

    subject {
      visit url
      find_field_element(:description)
    }

    context "index" do
      let!(:url) { "/admin/resources/products?view_type=table" }

      it { is_expected.to have_text empty_dash }
      it { expect(subject).not_to have_css "[data-controller='reveal-field']" }
    end

    context "show" do
      let!(:url) { "/admin/resources/products/#{product.to_param}" }

      it { is_expected.to have_text empty_dash }
      it { expect(subject).not_to have_css "[data-controller='reveal-field']" }
    end
  end

  describe "with a value" do
    let!(:product) { create :product, description: secret }

    subject {
      visit url
      find_field_element(:description)
    }

    shared_examples "a masked reveal field" do
      it "renders a masked control and keeps plaintext out of the field DOM" do
        expect(subject).to have_css "[data-controller='reveal-field']"
        expect(subject).to have_css "input[type='password'][readonly]"
        expect(subject).to have_css "[data-reveal-field-payload-value='#{encoded}']"

        input = subject.find("input")
        expect(input.value).to eq("••••••••")
        expect(input.value).not_to eq(secret)
      end
    end

    context "index" do
      let!(:url) { "/admin/resources/products?view_type=table" }

      it_behaves_like "a masked reveal field"
    end

    context "show" do
      let!(:url) { "/admin/resources/products/#{product.to_param}" }

      it_behaves_like "a masked reveal field"
    end

    context "edit" do
      let!(:url) { "/admin/resources/products/#{product.to_param}/edit" }

      it "is hidden on forms" do
        visit url

        expect(page).to have_no_css "[data-field-id='description'][data-field-type='reveal']"
      end
    end
  end
end
