require "rails_helper"

RSpec.feature "belongs_to", type: :feature do
  context "index" do
    describe "with a related user" do
      let!(:post) { create :post, user: admin }
    end
  end

  context "index" do
    let(:url) { "/avo/resources/posts?view_type=table" }

    subject do
      visit url
      find("[data-resource-id='#{post.id}'] [data-field-id='user']")
    end

    describe "with a related user" do
      let!(:post) { create :post, user: admin }

      it { is_expected.to have_text admin.name }
    end

    describe "without a related user" do
      let!(:post) { create :post }

      it { is_expected.to have_text empty_dash }
    end
  end
  subject do
    visit url
    find_field_value_element("user")
  end

  context "show" do
    let(:url) { "/avo/resources/posts/#{post.id}" }

    describe "with user attached" do
      let!(:post) { create :post, user: admin }

      it { is_expected.to have_link admin.name, href: "/avo/resources/users/#{admin.id}?via_resource_class=Post&via_resource_id=#{post.id}" }
    end

    describe "without user attached" do
      let!(:post) { create :post }

      it { is_expected.to have_text empty_dash }
    end
  end

  context "edit" do
    let(:url) { "/avo/resources/posts/#{post.id}/edit" }

    describe "without user attached" do
      let!(:post) { create :post, user: nil }

      it { is_expected.to have_select "post_user_id", selected: nil, options: [empty_dash, admin.name] }

      it "changes the user" do
        visit url
        expect(page).to have_select "post_user_id", selected: nil, options: [empty_dash, admin.name]

        select admin.name, from: "post_user_id"

        click_on "Save"

        expect(current_path).to eql "/avo/resources/posts/#{post.id}"
        expect(page).to have_link admin.name, href: "/avo/resources/users/#{admin.id}?via_resource_class=Post&via_resource_id=#{post.id}"
      end
    end

    describe "with user attached" do
      let!(:post) { create :post, user: admin }
      let!(:second_user) { create :user }

      it { is_expected.to have_select "post_user_id", selected: admin.name }

      it "changes the user" do
        visit url
        expect(page).to have_select "post_user_id", selected: admin.name

        select second_user.name, from: "post_user_id"

        click_on "Save"

        expect(current_path).to eql "/avo/resources/posts/#{post.id}"
        expect(page).to have_link second_user.name, href: "/avo/resources/users/#{second_user.id}?via_resource_class=Post&via_resource_id=#{post.id}"
      end

      it "nullifies the user" do
        visit url
        expect(page).to have_select "post_user_id", selected: admin.name

        select empty_dash, from: "post_user_id"

        click_on "Save"

        expect(current_path).to eql "/avo/resources/posts/#{post.id}"
        expect(find_field_value_element("user")).to have_text empty_dash
      end
    end
  end

  context "new" do
    let(:url) { "/avo/resources/posts/new?via_relation=user&via_relation_class=User&via_resource_id=#{admin.id}" }

    it { is_expected.to have_select "post_user_id", selected: admin.name, options: [empty_dash, admin.name], disabled: true }
  end
end
