require "rails_helper"

RSpec.describe "resource panel description", type: :feature do
  let(:empty) { ' ' }

  subject do
    visit url
    find_all("[data-target='description']").first
  end

  describe 'without description' do
    let(:url) { "/admin/resources/posts" }

    context "index" do
      it { is_expected.to have_text empty }
    end
  end

  describe 'with description' do
    describe 'with string' do
      let!(:person) { create :person }

      context "index" do
        let(:url) { "/admin/resources/people" }
        it { is_expected.to have_text 'People on the app' }
      end

      context "show" do
        let(:url) { "/admin/resources/people/#{person.id}" }
        it { is_expected.to have_text empty }
      end

      context "edit" do
        let(:url) { "/admin/resources/people/#{person.id}/edit" }
        it { is_expected.to have_text empty }
      end

      context "new" do
        let(:url) { "/admin/resources/people/new" }
        it { is_expected.to have_text empty }
      end
    end

    describe 'with block' do
      let!(:user) { create :user }

      context "index" do
        let(:url) { "/admin/resources/users" }
        it { is_expected.to have_text 'These are the users of the app. view: index' }
      end

      context "show" do
        let(:url) { "/admin/resources/users/#{user.id}" }
        it { is_expected.to have_text 'These are the users of the app. view: show' }
      end

      context "edit" do
        let(:url) { "/admin/resources/users/#{user.id}/edit" }
        it { is_expected.to have_text 'These are the users of the app. view: edit' }
      end

      context "new" do
        let(:url) { "/admin/resources/users/new" }
        it { is_expected.to have_text 'These are the users of the app. view: new' }
      end
    end
  end
end
