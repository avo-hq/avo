require "rails_helper"

RSpec.feature "FullWidthContainer", type: :feature do
  let(:user) { create :user }
  let(:contained_classes) { "justify-between items-stretch 2xl:container 2xl:mx-auto" }
  let(:is_contained) { is_expected.to include contained_classes }
  let(:is_not_contained) { is_expected.not_to include contained_classes }
  subject do
    visit url
    page.body
  end

  describe "full_width_container = true" do
    before do
      Avo.configuration.full_width_container = true
    end

    describe "full_width_index_view = true" do
      before do
        Avo.configuration.full_width_index_view = true
      end

      context ".index" do
        let(:url) { "/avo/resources/users" }

        it { is_not_contained }
      end

      context ".show" do
        let(:url) { "/avo/resources/users/#{user.id}" }

        it { is_not_contained }
      end
    end

    describe "full_width_index_view = false" do
      before do
        Avo.configuration.full_width_index_view = false
      end

      context ".index" do
        let(:url) { "/avo/resources/users" }

        it { is_not_contained }
      end

      context ".show" do
        let(:url) { "/avo/resources/users/#{user.id}" }

        it { is_not_contained }
      end
    end
  end

  describe "full_width_container = false" do
    before do
      Avo.configuration.full_width_container = false
    end

    describe "full_width_index_view = false" do
      before do
        Avo.configuration.full_width_index_view = false
      end

      context ".index" do
        let(:url) { "/avo/resources/users" }

        it { is_contained }
      end

      context ".show" do
        let(:url) { "/avo/resources/users/#{user.id}" }

        it { is_contained }
      end
    end

    describe "full_width_index_view = true" do
      before do
        Avo.configuration.full_width_index_view = true
      end

      context ".index" do
        let(:url) { "/avo/resources/users" }

        it { is_not_contained }
      end

      context ".show" do
        let(:url) { "/avo/resources/users/#{user.id}" }

        it { is_contained }
      end
    end
  end
end
