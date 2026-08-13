require "rails_helper"

RSpec.describe "Resizable rich text editors", type: :system do
  let(:long_content) { Array.new(100) { |index| "<p>Line #{index}</p>" }.join }
  let!(:product) { create :product, description: long_content }
  let!(:other_product) { create :product, description: "" }
  let!(:post) { create :post, body: long_content }

  before do
    visit "/admin/resources/products/#{product.id}/edit"
    clear_saved_editor_heights
    page.refresh
  end

  after do
    clear_saved_editor_heights
  end

  def clear_saved_editor_heights
    page.execute_script(<<~JS)
      Object.keys(window.localStorage)
        .filter((key) => key.startsWith('avo.resizableEditors.'))
        .forEach((key) => window.localStorage.removeItem(key))
    JS
  end

  def editor_styles(selector)
    page.evaluate_script(<<~JS)
      (() => {
        const editor = document.querySelector(#{selector.to_json})
        const styles = getComputedStyle(editor)

        return {
          height: editor.getBoundingClientRect().height,
          clientHeight: editor.clientHeight,
          scrollHeight: editor.scrollHeight,
          overflowY: styles.overflowY,
          resize: styles.resize
        }
      })()
    JS
  end

  def resize_editor(selector, height)
    page.execute_script(<<~JS)
      document.querySelector(#{selector.to_json}).style.height = '#{height}px'
    JS
    sleep 0.2
  end

  it "gives Tiptap and Trix the same bounded, vertically resizable viewport" do
    {
      ".tiptap.ProseMirror" => "/admin/resources/products/#{product.id}/edit",
      "trix-editor.trix-content" => "/admin/resources/posts/#{post.to_param}/edit"
    }.each do |selector, path|
      visit path

      expect(page).to have_selector("#{selector}.resizable-editor__viewport")

      styles = editor_styles(selector)
      expect(styles["height"]).to be_within(1).of(320)
      expect(styles["scrollHeight"]).to be > styles["clientHeight"]
      expect(styles["overflowY"]).to eq("auto")
      expect(styles["resize"]).to eq("vertical")
    end
  end

  it "persists a height across records while isolating different resource fields" do
    resize_editor(".tiptap.ProseMirror", 437)

    expect(
      page.evaluate_script(
        "window.localStorage.getItem('avo.resizableEditors.v1.%2Fadmin.resources.products.fields.description.height')"
      )
    ).to eq("437")

    visit "/admin/resources/products/#{other_product.id}/edit"
    expect(page).to have_selector(".tiptap.ProseMirror.resizable-editor__viewport")
    expect(editor_styles(".tiptap.ProseMirror")["height"]).to be_within(1).of(437)

    visit "/admin/resources/posts/#{post.to_param}/edit"
    expect(page).to have_selector("trix-editor.trix-content.resizable-editor__viewport")
    expect(editor_styles("trix-editor.trix-content")["height"]).to be_within(1).of(320)

    resize_editor("trix-editor.trix-content", 386)
    page.refresh

    expect(page).to have_selector("trix-editor.trix-content.resizable-editor__viewport")
    expect(editor_styles("trix-editor.trix-content")["height"]).to be_within(1).of(386)
  end
end
