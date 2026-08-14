require "rails_helper"

RSpec.describe "WYSIWYG fields More/Less content", type: :system do
  let(:rich_html) { "<h1>Title</h1>" + "<p>Long enough paragraph.</p>" * 20 }
  let(:markdown) { "# Title\n\n" + "Long enough paragraph.\n\n" * 20 }
  let!(:playground) do
    Playground.create!(
      name: "WYSIWYG showcase",
      lexxy_content: rich_html,
      rhino_content: rich_html,
      trix_content: rich_html,
      tiptap_content: rich_html,
      easy_mde_content: markdown,
      marksmith_content: markdown,
      code_value: "def hello\n  puts \"hello\"\nend\n" * 15
    )
  end

  field_ids = %w[lexxy_content rhino_content trix_content tiptap_content easy_mde_content marksmith_content code_value]

  it "collapses every field to a preview and toggles with More/Less content" do
    visit "/admin/resources/playgrounds/#{playground.id}"

    field_ids.each do |field_id|
      wrapper = find("[data-field-id='#{field_id}']")

      within wrapper do
        # Collapsed preview with the More content toggle revealed by trix-body.
        expect(page).to have_css("[data-trix-body-target='content'].hidden")
        expect(page).to have_link I18n.t("avo.more_content"), visible: true

        find("[data-trix-body-target='moreContentButton'] a").click

        expect(page).to have_css("[data-trix-body-target='content']:not(.hidden)")
        expect(page).to have_link I18n.t("avo.less_content"), visible: true

        find("[data-trix-body-target='lessContentButton'] a").click

        expect(page).to have_css("[data-trix-body-target='content'].hidden")
      end
    end
  end
end
