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

  # Lexxy requires Rails >= 8.0.2, so the field is absent on the Rails 7.1 appraisals.
  field_ids = %w[rhino_content trix_content tiptap_content easy_mde_content marksmith_content code_value]
  field_ids.unshift("lexxy_content") if defined?(Lexxy)

  it "mounts a resizable viewport for every editor on edit and persists the height" do
    visit "/admin/resources/playgrounds/#{playground.id}/edit"

    field_ids.each do |field_id|
      expect(page).to have_css("[data-field-id='#{field_id}'] .resizable-editor__viewport", wait: 10)
    end

    page.execute_script <<~JS
      const viewport = document.querySelector("[data-field-id='trix_content'] .resizable-editor__viewport")
      viewport.style.height = "444px"
      requestAnimationFrame(() => window.dispatchEvent(new Event("pointerup")))
    JS

    sleep 0.3
    visit "/admin/resources/playgrounds/#{playground.id}/edit"

    restored = page.evaluate_script <<~JS
      Math.round(document.querySelector("[data-field-id='trix_content'] .resizable-editor__viewport").getBoundingClientRect().height)
    JS

    expect(restored).to eq 444
  end

  it "collapses every field to a preview and toggles with More/Less content" do
    visit "/admin/resources/playgrounds/#{playground.id}"

    # Released marksmith (<= 0.5.2) doesn't render the collapsable show
    # wrapper yet; drop this once a version with `collapsable:` ships.
    collapsable_ids = field_ids - (Marksmith::VERSION <= "0.5.2" ? ["marksmith_content"] : [])

    collapsable_ids.each do |field_id|
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
