# frozen_string_literal: true

require "rails_helper"

RSpec.describe "TiptapField", type: :system do
  describe "without value" do
    let!(:product) { create :product, description: "" }

    context "show" do
      it "displays the products empty description (dash)" do
        visit "/admin/resources/products/#{product.id}"

        expect(find_field_element("description")).to have_text empty_dash
      end
    end

    context "edit" do
      it "has the products description label and empty tiptap editor and placeholder" do
        visit "/admin/resources/products/#{product.id}/edit"

        description_element = find_field_element("description")

        expect(description_element).to have_text "DESCRIPTION"

        expect(find("#tiptap_product_description_editor", visible: false)[:placeholder]).to have_text("Enter text")
        expect(find("#tiptap_product_description_editor", visible: false)).to have_text("")
      end

      it "change the products description text" do
        visit "/admin/resources/products/#{product.id}/edit"

        fill_in_tiptap_editor "tiptap_product_description", with: "Works for us!!!"

        save

        click_on "Show content"

        expect(find_field_value_element("description")).to have_text "Works for us!!!"
      end

      context "tiptap editor" do
        context "toolbar" do
          context "text style" do
            it "has a text bold button" do
              visit "/admin/resources/products/#{product.id}/edit"

              expect(find(".tiptap__toolbar")).to have_css(".tiptap__button--bold")
            end

            it "has a text italic button" do
              visit "/admin/resources/products/#{product.id}/edit"

              expect(find(".tiptap__toolbar")).to have_css(".tiptap__button--italic")
            end

            it "has a text underline button" do
              visit "/admin/resources/products/#{product.id}/edit"

              expect(find(".tiptap__toolbar")).to have_css(".tiptap__button--underline")
            end

            it "has a text strike button" do
              visit "/admin/resources/products/#{product.id}/edit"

              expect(find(".tiptap__toolbar")).to have_css(".tiptap__button--strike")
            end
          end

          context "text alignment" do
            it "has a text align left button" do
              visit "/admin/resources/products/#{product.id}/edit"

              expect(find(".tiptap__toolbar")).to have_css(".tiptap__button--align-left")
            end

            it "has a text align center button" do
              visit "/admin/resources/products/#{product.id}/edit"

              expect(find(".tiptap__toolbar")).to have_css(".tiptap__button--align-center")
            end

            it "has a text align right button" do
              visit "/admin/resources/products/#{product.id}/edit"

              expect(find(".tiptap__toolbar")).to have_css(".tiptap__button--align-right")
            end

            it "has a text align justify button" do
              visit "/admin/resources/products/#{product.id}/edit"

              expect(find(".tiptap__toolbar")).to have_css(".tiptap__button--align-justify")
            end
          end

          context "text list" do
            it "has a text bullet list button" do
              visit "/admin/resources/products/#{product.id}/edit"

              expect(find(".tiptap__toolbar")).to have_css(".tiptap__button--ul")
            end

            it "has a text ordered list button" do
              visit "/admin/resources/products/#{product.id}/edit"

              expect(find(".tiptap__toolbar")).to have_css(".tiptap__button--ol")
            end
          end

          context "text link" do
            it "has a text link button" do
              visit "/admin/resources/products/#{product.id}/edit"

              expect(find(".tiptap__toolbar")).to have_css(".tiptap__button--link")
            end
          end
        end
      end
    end
  end

  describe "with regular value" do
    let!(:description) { "<div>Example tiptap text.</div>" }
    let!(:product) { create :product, description: description }

    context "show" do
      it "displays the products description" do
        visit "/admin/resources/products/#{product.id}"

        click_on "Show content"

        expect(find_field_value_element("description")).to have_text ActionView::Base.full_sanitizer.sanitize(description)
      end
    end

    context "edit" do
      it "has the products description label" do
        visit "/admin/resources/products/#{product.id}/edit"

        description_element = find_field_element("description")

        expect(description_element).to have_text "DESCRIPTION"
      end

      it "has filled simple text in tiptap editor" do
        visit "/admin/resources/products/#{product.id}/edit"

        expect(find("#tiptap_product_description", visible: false).value).to eq(description)
      end

      it "change the products description tiptap to another simple text value" do
        visit "/admin/resources/products/#{product.id}/edit"

        fill_in_tiptap_editor "tiptap_product_description", with: "New example!"

        save
        click_on "Show content"

        expect(find_field_value_element("description")).to have_text "New example!"
      end
    end
  end
end

def fill_in_tiptap_editor(id, with:)
  find("##{id}_editor").find(".ProseMirror").click.set(with)
end
