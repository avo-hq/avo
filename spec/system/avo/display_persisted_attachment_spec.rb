require "rails_helper"

RSpec.describe "DisplayPersistedAttachment", type: :system do
  describe "display persisted image on edit view" do
    let(:post) do
      create(:post) do |p|
        p.cover_photo.attach(
          io: File.open(Rails.root.join("db", "seed_files", "iphone.jpg")),
          filename: "iphone.jpg",
          content_type: "image/jpeg"
        )
      end
    end

    it "displays persisted image on edit view" do
      visit "/admin/resources/posts/#{post.to_param}/edit"
      fill_in "Name", with: ""
      attach_file Rails.root.join("db", "seed_files", "dummy-image.jpg"), id: "post_cover_photo"

      click_button "Save"
      wait_for_loaded

      expect(page).to have_selector 'div[data-field-id="cover_photo"] img'
    end
  end

  describe "display persisted audio on edit view" do
    let(:post) do
      create(:post) do |p|
        p.audio.attach(
          io: File.open(Rails.root.join("db", "seed_files", "dummy-music.mp3")),
          filename: "dummy-music.mp3",
          content_type: "audio/mp3"
        )
      end
    end

    it "displays persisted audio on edit view" do
      visit "/admin/resources/posts/#{post.to_param}/edit"
      fill_in "Name", with: ""
      attach_file Rails.root.join("db", "seed_files", "dummy-music-two.mp3"), id: "post_audio"

      click_button "Save"
      wait_for_loaded

      expect(page).to have_selector "audio"
    end
  end
end
