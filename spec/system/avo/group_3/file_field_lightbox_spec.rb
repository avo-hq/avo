require "rails_helper"

RSpec.describe "File field lightbox", type: :system do
  include ActionView::RecordIdentifier

  let(:project) do
    create(:project) do |p|
      %w[iphone.jpg ipod.jpg].each do |name|
        p.files.attach(io: Rails.root.join("db", "seed_files", name).open, filename: name, content_type: "image/jpeg")
      end
    end
  end

  after { Avo::Resources::Project.restore_items_from_backup }

  def lightbox
    find("dialog.lightbox[open]")
  end

  def expect_lightbox_to_show(filename)
    expect(lightbox).to have_css(".lightbox__caption", text: filename)
    expect(lightbox.find(".lightbox__image")[:src]).to end_with("/#{filename}")
  end

  describe "files field in grid view" do
    before do
      Avo::Resources::Project.with_temporary_items do
        field :files, as: :files, view_type: :grid, hide_view_type_switcher: true
      end

      visit avo.resources_project_path(project)
    end

    it "opens the clicked image and cycles through the field's images" do
      expect(page).not_to have_css("dialog.lightbox[open]")

      within("##{dom_id(project.files.first)}") { find(".lightbox__trigger").click }

      expect_lightbox_to_show "iphone.jpg"
      expect(lightbox).to have_css(".lightbox__counter", text: "1 / 2")
      expect(lightbox.find(".lightbox__caption")[:title]).to eq "iphone.jpg"
      expect(lightbox.find(".lightbox__toolbar a[target='_blank']")[:href]).to end_with("/iphone.jpg")

      lightbox.find(".lightbox__nav--next").click
      expect_lightbox_to_show "ipod.jpg"
      expect(lightbox).to have_css(".lightbox__counter", text: "2 / 2")

      lightbox.find(".lightbox__nav--prev").click
      expect_lightbox_to_show "iphone.jpg"
    end

    it "navigates with the arrow keys and closes with Escape" do
      within("##{dom_id(project.files.first)}") { find(".lightbox__trigger").click }
      expect_lightbox_to_show "iphone.jpg"

      find("body").native.send_keys(:right)
      expect_lightbox_to_show "ipod.jpg"

      find("body").native.send_keys(:left)
      expect_lightbox_to_show "iphone.jpg"

      find("body").native.send_keys(:escape)
      expect(page).not_to have_css("dialog.lightbox[open]")
      expect(page).to have_css("##{dom_id(project.files.first)} img")
    end

    it "closes on a click outside the image" do
      within("##{dom_id(project.files.last)}") { find(".lightbox__trigger").click }
      expect_lightbox_to_show "ipod.jpg"

      # Ferrum's real mouse at the viewport corner: Capybara's click offsets are measured from
      # the element's center, which is the image.
      page.driver.browser.mouse.click(x: 20, y: 20)
      expect(page).not_to have_css("dialog.lightbox[open]")
    end

    it "keeps the global hotkeys from acting behind the lightbox" do
      within("##{dom_id(project.files.first)}") { find(".lightbox__trigger").click }
      expect_lightbox_to_show "iphone.jpg"

      # "c" opens the resource's new page from a show page unless a modal is open.
      find("body").native.send_keys("c")
      sleep 0.5

      expect(page).to have_current_path(avo.resources_project_path(project))
      expect(page).to have_css("dialog.lightbox[open]")
    end
  end

  describe "files field in list view" do
    before do
      Avo::Resources::Project.with_temporary_items do
        field :files, as: :files, view_type: :list, hide_view_type_switcher: true
      end

      visit avo.resources_project_path(project)
    end

    it "opens the lightbox from the preview control" do
      within("##{dom_id(project.files.last)}") { find("[data-image-lightbox-target='item']").click }

      expect_lightbox_to_show "ipod.jpg"
      expect(lightbox).to have_css(".lightbox__counter", text: "2 / 2")
    end
  end

  describe "lightbox: false" do
    before do
      Avo::Resources::Project.with_temporary_items do
        field :files, as: :files, view_type: :grid, hide_view_type_switcher: true, lightbox: false
      end

      visit avo.resources_project_path(project)
    end

    it "renders the plain image without a lightbox" do
      expect(page).to have_css("##{dom_id(project.files.first)} img")
      expect(page).not_to have_css(".lightbox__trigger")
      expect(page).not_to have_css("[data-controller='image-lightbox']")
      expect(page).not_to have_css("dialog.lightbox", visible: :all)
    end
  end

  describe "display_filename: false" do
    before do
      Avo::Resources::Project.with_temporary_items do
        field :files, as: :files, view_type: :grid, hide_view_type_switcher: true, display_filename: false
      end

      visit avo.resources_project_path(project)
    end

    it "keeps the filename out of the trigger label, the caption and the alt text" do
      trigger = within("##{dom_id(project.files.first)}") { find(".lightbox__trigger") }
      expect(trigger["aria-label"]).to eq "Image preview"

      trigger.click

      expect(lightbox.find(".lightbox__image")[:src]).to end_with("/iphone.jpg")
      expect(lightbox.find(".lightbox__image")[:alt]).to eq ""
      expect(lightbox).not_to have_css(".lightbox__caption")
      expect(lightbox).not_to have_text("iphone.jpg")
    end
  end

  describe "file field" do
    let(:post) do
      create(:post) do |p|
        p.cover.attach(io: Rails.root.join("db", "seed_files", "iphone.jpg").open, filename: "iphone.jpg", content_type: "image/jpeg")
      end
    end

    it "opens the single image without navigation controls" do
      visit avo.resources_post_path(post)

      within("##{dom_id(post.cover)}") { find(".lightbox__trigger").click }

      expect_lightbox_to_show "iphone.jpg"
      expect(lightbox).not_to have_css(".lightbox__nav--prev")
      expect(lightbox).not_to have_css(".lightbox__nav--next")
      expect(lightbox).not_to have_css(".lightbox__counter")
    end
  end
end
