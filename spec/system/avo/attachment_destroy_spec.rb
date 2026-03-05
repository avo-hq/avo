require "rails_helper"

RSpec.describe "Attachment destroy", type: :system do
  describe "destroying an attachment" do
    context "when validation fails after destroying attachment" do
      let(:post_record) do
        create(:post) do |p|
          p.cover_photo.attach(
            io: File.open(Rails.root.join("db", "seed_files", "iphone.jpg")),
            filename: "iphone.jpg",
            content_type: "image/jpeg"
          )
        end
      end

      it "rolls back the transaction and keeps the attachment" do
        attachment_id = post_record.cover_photo.id

        # Make the name blank so validation fails on save
        # (name has presence: true validation that definitely works)
        post_record.update_column(:name, nil)

        visit "/admin/resources/posts/#{post_record.to_param}"

        destroy_path = "/admin/resources/posts/#{post_record.to_param}/active_storage_attachments/cover_photo/#{attachment_id}"

        expect {
          accept_custom_alert do
            find("a[data-turbo-method='delete'][href='#{destroy_path}']").click
          end
          wait_for_loaded
        }.not_to change { ActiveStorage::Attachment.count }

        # Flash should contain validation error
        expect(page).to have_text("Name can't be blank")

        # Attachment should still exist
        expect(ActiveStorage::Attachment.exists?(attachment_id)).to be true

        # Post should still have the cover_photo
        post_record.reload
        expect(post_record.cover_photo).to be_attached
      end
    end

    context "when destroying an attachment succeeds" do
      let(:post_record) do
        create(:post) do |p|
          p.cover_photo.attach(
            io: File.open(Rails.root.join("db", "seed_files", "iphone.jpg")),
            filename: "iphone.jpg",
            content_type: "image/jpeg"
          )
          p.audio.attach(
            io: File.open(Rails.root.join("db", "seed_files", "dummy-audio.mp3")),
            filename: "dummy-audio.mp3",
            content_type: "audio/mp3"
          )
        end
      end

      it "destroys the attachment and saves the record" do
        audio_attachment_id = post_record.audio.id

        visit "/admin/resources/posts/#{post_record.to_param}"

        destroy_path = "/admin/resources/posts/#{post_record.to_param}/active_storage_attachments/audio/#{audio_attachment_id}"

        expect {
          accept_custom_alert do
            find("a[data-turbo-method='delete'][href='#{destroy_path}']").click
          end
          wait_for_loaded
        }.to change { ActiveStorage::Attachment.count }.by(-1)

        # Flash should indicate success
        expect(page).to have_text("Attachment destroyed")

        # Audio attachment should no longer exist
        expect(ActiveStorage::Attachment.exists?(audio_attachment_id)).to be false

        # Post should no longer have the audio
        post_record.reload
        expect(post_record.audio).not_to be_attached
      end
    end
  end
end
