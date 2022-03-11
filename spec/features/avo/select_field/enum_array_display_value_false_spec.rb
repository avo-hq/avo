require "rails_helper"

RSpec.describe "SelectField", type: :feature do
  describe "enum array display_value: false" do
    context "index" do
      let(:url) { "/admin/resources/posts?view_type=table" }
      subject do
        visit url
        field_element_by_resource_id "status", post.id
      end

      describe "without status" do
        let!(:post) { create :post, status: nil }

        it { is_expected.to have_text empty_dash }
      end

      describe "with draft status" do
        let(:status) { "draft" }
        let!(:post) { create :post, status: 0 }

        it { is_expected.to have_text status }
      end

      describe "with published status" do
        let(:status) { "published" }
        let!(:post) { create :post, status: 1 }

        it { is_expected.to have_text status }
      end

      describe "with archived status" do
        let(:status) { "archived" }
        let!(:post) { create :post, status: 2 }

        it { is_expected.to have_text status }
      end
    end

    subject do
      visit url
      find_field_value_element("status")
    end

    context "show" do
      let(:url) { "/admin/resources/posts/#{post.id}" }

      describe "without status" do
        let!(:post) { create :post, status: nil }

        it { is_expected.to have_text empty_dash }
      end

      describe "with draft status" do
        let(:status) { "draft" }
        let!(:post) { create :post, status: 0 }

        it { is_expected.to have_text status }
      end

      describe "with published status" do
        let(:status) { "published" }
        let!(:post) { create :post, status: 1 }

        it { is_expected.to have_text status }
      end

      describe "with archived status" do
        let(:status) { "archived" }
        let!(:post) { create :post, status: 2 }

        it { is_expected.to have_text status }
      end
    end

    let(:statuses_without_placeholder) { ["draft", "published", "archived"] }
    let(:placeholder) { "Choose an option" }
    let(:statuses_with_placeholder) { statuses_without_placeholder.prepend(placeholder) }

    context "edit" do
      let(:url) { "/admin/resources/posts/#{post.id}/edit" }

      describe "without status" do
        let!(:post) { create :post, status: nil }
        let(:new_status) { "published" }

        it { is_expected.to have_select "post_status", selected: nil, options: statuses_with_placeholder }

        it "sets the status to idea" do
          visit url

          expect(page).to have_select "post_status", selected: nil, options: statuses_with_placeholder

          select new_status, from: "post_status"

          click_on "Save"

          expect(current_path).to eql "/admin/resources/posts/#{post.id}"
          expect(page).to have_text new_status
        end
      end

      describe "with status" do
        let(:status) { "draft" }
        let(:new_status) { "published" }
        let!(:post) { create :post, status: status }

        it { is_expected.to have_select "post_status", selected: status, options: statuses_without_placeholder }

        it "changes the status to published" do
          visit url
          expect(page).to have_select "post_status", selected: status, options: statuses_without_placeholder

          select new_status, from: "post_status"

          click_on "Save"

          expect(current_path).to eql "/admin/resources/posts/#{post.id}"
          expect(page).to have_text new_status
        end
      end
    end

    context "create" do
      let(:url) { "/admin/resources/posts/new" }
      let(:new_status) { "published" }

      describe "creates new post with status published" do
        it "checks placeholder" do
          is_expected.to have_select "post_status", selected: 'draft', options: statuses_without_placeholder
        end

        it "saves the resource with status published" do
          visit url
          expect(page).to have_select "post_status", selected: 'draft', options: statuses_without_placeholder

          fill_in "post_name", with: "Post X"
          select new_status, from: "post_status"

          click_on "Save"

          expect(current_path).to eql "/admin/resources/posts/#{Post.last.id}"
          expect(page).to have_text "Post X"
          expect(page).to have_text "published"
        end
      end
    end
  end
end
