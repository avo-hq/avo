require 'rails_helper'

RSpec.feature 'Lightbox', type: :feature do
  describe 'Lightbox functionality' do
    let(:image_path) { Rails.root.join('..', 'fixtures', 'files', 'test_image.jpg') }

    let!(:post) do
      post = create(:post)
      post.cover_photo.attach(
        io: File.open(image_path),
        filename: 'test_image.jpg',
        content_type: 'image/jpeg'
      )
      post
    end

    it 'displays clicked image in a lightbox modal and closes the modal when the close button is clicked' do
      Avo::Resources::Post.with_temporary_items do
        field :cover_photo, as: :file, is_image: true, full_width: true, hide_on: [], accept: 'image/*',
                            stacked: true
      end

      visit "/admin/resources/posts/#{post.id}"

      expect(page).to have_selector('[data-lightbox-target="modal"].hidden')

      cover_photo_image = find("img[data-action='click->lightbox#open']", visible: true)
      cover_photo_image.click

      visible_modal = find('[data-lightbox-target="modal"]')
      expect(visible_modal).to have_selector('img[data-lightbox-target="image"]')
      expect(visible_modal).to have_selector('button[data-action="click->lightbox#close"]')

      close_lightbox_modal_button = find('button[data-action="click->lightbox#close"]', visible: true)
      close_lightbox_modal_button.click
      expect(page).to have_selector('[data-lightbox-target="modal"].hidden')

      Avo::Resources::Post.restore_items_from_backup
    end
  end
end
