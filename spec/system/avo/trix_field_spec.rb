require "rails_helper"

RSpec.describe "TrixField", type: :system do
  describe "without value" do
    let!(:post) { create :post, body: "" }

    context "show" do
      it "displays the posts empty body (dash)" do
        visit "/avo/resources/posts/#{post.id}"

        expect(find_field_element("body")).to have_text empty_dash
      end
    end

    context "edit" do
      it "has the posts body label and empty trix editor and placeholder" do
        visit "/avo/resources/posts/#{post.id}/edit"

        body_element = find_field_element("body")

        expect(body_element).to have_text "Body"

        expect(find("#trix_post_body", visible: false)[:placeholder]).to have_text("Enter text")
        expect(find("#trix_post_body", visible: false)).to have_text("")
      end

      it "change the posts body text" do
        visit "/avo/resources/posts/#{post.id}/edit"

        fill_in_trix_editor "trix_post_body", with: "Works for us!!!"

        click_on "Save"
        click_on "Show content"

        expect(find_field_value_element("body")).to have_text "Works for us!!!"
      end
    end
  end

  describe "with regular value" do
    let!(:body) { "<div>Example trix text.</div>" }
    let!(:post) { create :post, body: body }

    context "show" do
      it "displays the posts body" do
        visit "/avo/resources/posts/#{post.id}"

        click_on "Show content"

        expect(find_field_value_element("body")).to have_text ActionView::Base.full_sanitizer.sanitize(body)
      end
    end

    context "edit" do
      it "has the posts body label" do
        visit "/avo/resources/posts/#{post.id}/edit"

        body_element = find_field_element("body")

        expect(body_element).to have_text "Body"
      end

      it "has filled simple text in trix editor" do
        visit "/avo/resources/posts/#{post.id}/edit"

        expect(find("#trix_post_body", visible: false).value).to eq(body)
      end

      it "change the posts body trix to another simple text value" do
        visit "/avo/resources/posts/#{post.id}/edit"

        fill_in_trix_editor "trix_post_body", with: "New example!"

        click_on "Save"
        click_on "Show content"

        expect(find_field_value_element("body")).to have_text "New example!"
      end
    end
  end
end

def fill_in_trix_editor(id, with:)
  find("trix-editor[input='#{id}']").click.set(with)
end
