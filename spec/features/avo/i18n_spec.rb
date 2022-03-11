require "rails_helper"

RSpec.feature "i18n", type: :feature do
  let(:user) { User.first }
  let!(:post) { create :post, user: user }

  describe "field translation_key" do
    describe "resource index (has_many)" do
      it 'translation on the panel title' do
        visit "/admin/resources/users/#{user.id}/people?turbo_frame=has_many_field_show_people"

        expect(find("[data-target='title']").text).to eq "Peeps"
      end
    end

    describe "resource show (has_one)" do
      it 'translation on the panel title' do
        visit "/admin/resources/users/#{user.id}/post/#{post.id}?turbo_frame=has_one_field_show_post"

        expect(find("[data-target='title']").text).to eq "Peep"
      end
    end
  end
end
