require "rails_helper"

RSpec.describe "CodeField", type: :system do
  describe "without value" do
    let!(:user) { create :user, custom_css: "" }

    context "show" do
      it "displays the projects empty custom_css (dash)" do
        visit "/admin/resources/users/#{user.id}"
        wait_for_loaded

        expect(find_field_value_element("custom_css")).to have_text empty_dash
      end
    end

    context "edit" do
      it "has the projects custom_css label and empty code editor" do
        visit "/admin/resources/users/#{user.id}/edit"
        wait_for_loaded

        custom_css_element = find_field_element("custom_css")

        expect(custom_css_element).to have_text "CUSTOM CSS"

        expect(custom_css_element).to have_css ".CodeMirror"
        expect(page).to have_editor_display text: ""
      end

      it "change the projects custom_css code" do
        visit "/admin/resources/users/#{user.id}/edit"
        wait_for_loaded

        fill_in_editor_field "Hello World"

        save

        expect(page).to have_editor_display text: "Hello World"
      end
    end
  end

  describe "with regular value" do
    let!(:css) { ".input { background: #000000; }" }
    let!(:user) { create :user, custom_css: css }

    context "edit" do
      it "has the projects custom_css label and filled code editor" do
        visit "/admin/resources/users/#{user.id}/edit"

        custom_css_element = find_field_element("custom_css")

        expect(custom_css_element).to have_text "CUSTOM CSS"

        expect(custom_css_element).to have_css ".CodeMirror"
        expect(page).to have_editor_display text: css
      end

      it "change the projects custom_css code to another value" do
        visit "/admin/resources/users/#{user.id}/edit"
        wait_for_loaded

        fill_in_editor_field ".input { background: #ffffff; }"

        save

        expect(page).to have_editor_display text: ".input { background: #ffffff; }"
      end
    end

    context "show" do
      it "displays the projects custom_css" do
        visit "/admin/resources/users/#{user.id}"
        wait_for_loaded

        expect(page).to have_editor_display text: css
      end
    end
  end

  def fill_in_editor_field(text)
    within ".CodeMirror" do
      current_scope.click
      type text
    end
  end

  def have_editor_display(options)
    editor_display_locator = ".CodeMirror-code"
    have_css(editor_display_locator, **options)
  end
end
