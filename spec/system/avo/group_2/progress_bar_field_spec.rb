require "rails_helper"
require "vips"

RSpec.describe "ProgressBarField", type: :system do
  describe "renders a visible fill" do
    let!(:project) { create :project, progress: 27 }

    # The native <progress> fill is painted by a browser pseudo-element whose
    # color is not exposed via getComputedStyle, so we screenshot the bar and
    # compare a pixel inside the filled zone (left, within the 27% value) to one
    # in the empty track (right). When the fill token is undefined the bar is
    # "all white" and both pixels match.
    def fill_and_track_pixels
      path = Rails.root.join("tmp", "progress_#{SecureRandom.hex(4)}.png").to_s
      page.driver.save_screenshot(path, selector: "[data-field-id='progress'] progress")

      image = Vips::Image.new_from_file(path)
      y = image.height / 2
      filled = image.getpoint((image.width * 0.12).to_i, y).first(3)
      track = image.getpoint((image.width * 0.88).to_i, y).first(3)
      {filled: filled, track: track}
    ensure
      File.delete(path) if path && File.exist?(path)
    end

    shared_examples "a visible progress fill" do
      it "fills with a color distinct from the track" do
        expect(page).to have_css "[data-field-id='progress'] progress[value='27']"

        pixels = fill_and_track_pixels
        expect(pixels[:filled]).not_to eq(pixels[:track]),
          "progress fill #{pixels[:filled]} matches the track #{pixels[:track]} — bar is invisible"
      end
    end

    context "on index" do
      before { visit "/admin/resources/projects/?view_type=table" }
      it_behaves_like "a visible progress fill"
    end

    context "on show" do
      before { visit "/admin/resources/projects/#{project.id}" }
      it_behaves_like "a visible progress fill"
    end
  end

  describe "able to contain nil value" do
    context "create" do
      it "progress field remains blank" do
        visit "/admin/resources/projects/new"

        fill_in "project[users_required]", with: 10

        click_button "Save"
        sleep 2

        expect(Project.last.progress).to eq(nil)
      end
    end
  end
end
