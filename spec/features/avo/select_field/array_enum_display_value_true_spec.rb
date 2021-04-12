require "rails_helper"

RSpec.describe "SelectField", type: :feature do
  describe "array enum display_value: true" do
    before do
      replace_field_declaration PostResource, :status do
        field :status, as: :select, enum: ::Post.statuses, display_value: true
      end
    end

    after do
      revert_to_original PostResource
    end

    context "index" do
      let(:url) { "/avo/resources/posts?view_type=table" }

      subject do
        visit url
        find("[data-resource-id='#{post.id}'] [data-field-id='status']")
      end

      describe "without status" do
        let!(:post) { create :post, status: nil }

        it { is_expected.to have_text empty_dash }
      end

      describe "with draft status" do
        let(:status_id) { 0 }
        let(:status) { "draft" }
        let!(:post) { create :post, status: status_id }

        it { is_expected.to have_text status_id }
      end

      describe "with published status" do
        let(:status_id) { 1 }
        let(:status) { 'published' }
        let!(:post) { create :post, status: status }

        it { is_expected.to have_text status_id }
      end

      describe "with archived status" do
        let(:status_id) { 2 }
        let(:status) { "archived" }
        let!(:post) { create :post, status: status }

        it { is_expected.to have_text status_id }
      end
    end

    subject do
      visit url
      find_field_value_element("status")
    end

    context "show" do
      let(:url) { "/avo/resources/posts/#{post.id}" }

      describe "without status" do
        let!(:post) { create :post, status: nil }

        it { is_expected.to have_text empty_dash }
      end

      describe "with draft status" do
        let(:status_id) { 0 }
        let(:status) { "draft" }
        let!(:post) { create :post, status: status_id }

        it { is_expected.to have_text status_id }
      end

      describe "with published status" do
        let(:status_id) { 1 }
        let(:status) { "published" }
        let!(:post) { create :post, status: status_id }

        it { is_expected.to have_text status_id }
      end

      describe "with archived status" do
        let(:status_id) { 2 }
        let(:status) { "archived" }
        let!(:post) { create :post, status: status_id }

        it { is_expected.to have_text status_id }
      end
    end

    let(:statuses_without_placeholder) { ["draft", "published", "archived"] }
    let(:placeholder) { "Choose an option" }
    let(:statuses_with_placeholder) { statuses_without_placeholder.dup.prepend(placeholder) }

    context "edit" do
      let(:url) { "/avo/resources/posts/#{post.id}/edit" }

      describe "without status" do
        let(:status_id) { 0 }
        let!(:post) { create :post, status: nil }
        let(:new_status) { "draft" }

        it { is_expected.to have_select "post_status", selected: nil, options: statuses_with_placeholder }

        it "sets the status to draft" do
          visit url

          expect(page).to have_select "post_status", selected: nil, options: statuses_with_placeholder

          select new_status, from: "post_status"

          click_on "Save"

          expect(current_path).to eql "/avo/resources/posts/#{post.id}"
          expect(page).to have_text new_status

          click_on "Edit"
          expect(page).to have_select "post_status", selected: status_id, options: statuses_without_placeholder
        end
      end

      describe "with status" do
        let(:status_id) { 0 }
        let(:status) { "draft" }
        let(:new_status_id) { 1 }
        let(:new_status) { "published" }
        let!(:post) { create :post, status: status_id }

        it { is_expected.to have_select "post_status", selected: status_id, options: statuses_without_placeholder }

        it "changes the status to on hold" do
          visit url
          expect(page).to have_select "post_status", selected: status_id, options: statuses_without_placeholder

          select new_status, from: "post_status"

          click_on "Save"

          expect(current_path).to eql "/avo/resources/posts/#{post.id}"
          expect(page).to have_text new_status

          click_on "Edit"
          expect(page).to have_select "post_status", selected: new_status_id, options: statuses_without_placeholder
        end
      end
    end

    context "create" do
      let(:url) { "/avo/resources/posts/new" }

      describe "creates new post with status published" do
        it "checks placeholder" do
          is_expected.to have_select "post_status", selected: nil, options: statuses_with_placeholder
        end

        it "saves the resource with status published" do
          visit url
          expect(page).to have_select "post_status", selected: nil, options: statuses_with_placeholder

          fill_in "post_name", with: "Post X"
          select "published", from: "post_status"

          click_on "Save"

          expect(current_path).to eql "/avo/resources/posts/#{Post.last.id}"
          expect(page).to have_text "Post X"
          expect(page).to have_text status_id
        end
      end
    end
  end
end
