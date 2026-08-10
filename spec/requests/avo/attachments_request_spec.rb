require "rails_helper"

RSpec.describe "Attachments", type: :request do
  include ActionDispatch::TestProcess

  let(:admin_user) do
    User.create!(
      first_name: "Admin",
      last_name: "User",
      email: "admin@example.com",
      password: "password",
      roles: {"admin" => true}
    )
  end

  let(:post_record) do
    Post.create!(name: "Hello", body: "World", user: admin_user)
  end

  def build_upload(content:, original_filename:, content_type:)
    tmp = Tempfile.new(["upload", File.extname(original_filename)])
    tmp.binmode
    tmp.write(content)
    tmp.rewind

    Rack::Test::UploadedFile.new(tmp.path, content_type, original_filename: original_filename)
  end

  it "denies has_one_attached upload when upload_cover_photo? is false" do
    sign_in admin_user

    post_record.cover_photo.attach(
      io: StringIO.new("old"),
      filename: "old.txt",
      content_type: "text/plain"
    )

    allow_any_instance_of(Avo::Services::AuthorizationService)
      .to receive(:authorize_action)
      .with("upload_cover_photo?", record: post_record, raise_exception: false)
      .and_return(false)

    upload = build_upload(content: "new", original_filename: "new.txt", content_type: "text/plain")
    old_blob_id = post_record.reload.cover_photo.blob_id
    old_checksum = post_record.cover_photo.blob.checksum

    expect {
      post "/admin/avo_api/resources/posts/#{post_record.to_param}/attachments",
        params: {file: upload, filename: "new.txt", attachment_key: "cover_photo"},
        headers: {"ACCEPT" => "application/json"}
    }.not_to change { ActiveStorage::Blob.count }

    post_record.reload
    expect(post_record.cover_photo).to be_attached
    expect(post_record.cover_photo.blob_id).to eq(old_blob_id)
    expect(post_record.cover_photo.blob.checksum).to eq(old_checksum)

    expect(response).to have_http_status(:forbidden)
  end

  it "denies has_many_attached upload when upload_attachments? is false" do
    sign_in admin_user

    allow_any_instance_of(Avo::Services::AuthorizationService)
      .to receive(:authorize_action)
      .with("upload_attachments?", record: post_record, raise_exception: false)
      .and_return(false)

    upload = build_upload(content: "one", original_filename: "one.txt", content_type: "text/plain")

    expect {
      post "/admin/avo_api/resources/posts/#{post_record.to_param}/attachments",
        params: {file: upload, filename: "one.txt", attachment_key: "attachments"},
        headers: {"ACCEPT" => "application/json"}
    }.not_to change { ActiveStorage::Blob.count }

    expect(post_record.reload.attachments.count).to eq(0)
    expect(response).to have_http_status(:forbidden)
  end

  it "denies key/Trix-style upload when no attachment association is resolved" do
    sign_in admin_user

    allow_any_instance_of(Avo::Services::AuthorizationService)
      .to receive(:authorize_action)
      .with("update?", record: post_record, raise_exception: false)
      .and_return(false)

    upload = build_upload(content: "trix", original_filename: "trix.txt", content_type: "text/plain")

    expect {
      post "/admin/avo_api/resources/posts/#{post_record.to_param}/attachments",
        params: {file: upload, filename: "trix.txt", attachment_key: "missing_field", key: "trixKey"},
        headers: {"ACCEPT" => "application/json"}
    }.not_to change { ActiveStorage::Blob.count }

    expect(response).to have_http_status(:forbidden)
  end

  describe "DELETE destroy" do
    # The authorization check runs against the record named by `:id`, while the
    # attachment to destroy comes from `:attachment_id`. Nothing may allow the
    # second to point outside the first.
    let(:other_post) { Post.create!(name: "Other", body: "Post", user: admin_user) }

    def attach(record, name, content)
      record.public_send(name).attach(
        io: StringIO.new(content),
        filename: "#{content}.txt",
        content_type: "text/plain"
      )

      ActiveStorage::Attachment.find_by!(record: record, name: name)
    end

    def destroy_attachment(record, attachment_name, attachment_id)
      delete "/admin/resources/posts/#{record.to_param}/active_storage_attachments/#{attachment_name}/#{attachment_id}",
        headers: {"ACCEPT" => "text/vnd.turbo-stream.html"}
    end

    before { sign_in admin_user }

    it "does not destroy an attachment belonging to another record" do
      attach(post_record, :cover_photo, "mine")
      victim = attach(other_post, :cover_photo, "victim")

      expect {
        destroy_attachment(post_record, "cover_photo", victim.id)
      }.not_to change { ActiveStorage::Attachment.exists?(victim.id) }.from(true)

      expect(other_post.reload.cover_photo).to be_attached
    end

    it "does not destroy an attachment belonging to another model" do
      attach(post_record, :cover_photo, "mine")

      project = create(:project)
      victim = attach(project, :files, "victim")

      expect {
        destroy_attachment(post_record, "cover_photo", victim.id)
      }.not_to change { ActiveStorage::Attachment.exists?(victim.id) }.from(true)

      expect(project.reload.files).to be_attached
    end

    it "does not destroy an attachment from another field on the same record" do
      attach(post_record, :cover_photo, "mine")
      victim = attach(post_record, :audio, "victim")

      expect {
        destroy_attachment(post_record, "cover_photo", victim.id)
      }.not_to change { ActiveStorage::Attachment.exists?(victim.id) }.from(true)

      expect(post_record.reload.audio).to be_attached
    end

    it "does not destroy anything when the attachment name is not an attachment on the record" do
      mine = attach(post_record, :cover_photo, "mine")

      expect {
        destroy_attachment(post_record, "not_an_attachment", mine.id)
      }.not_to change { ActiveStorage::Attachment.exists?(mine.id) }.from(true)
    end

    it "destroys the attachment when it belongs to the record and the named association" do
      mine = attach(post_record, :cover_photo, "mine")

      expect {
        destroy_attachment(post_record, "cover_photo", mine.id)
      }.to change { ActiveStorage::Attachment.exists?(mine.id) }.from(true).to(false)

      expect(post_record.reload.cover_photo).not_to be_attached
    end

    it "does not destroy the attachment when the delete policy denies it" do
      mine = attach(post_record, :cover_photo, "mine")

      allow_any_instance_of(Avo::Services::AuthorizationService)
        .to receive(:authorize_action)
        .with("delete_cover_photo?", record: post_record, raise_exception: false)
        .and_return(false)

      expect {
        destroy_attachment(post_record, "cover_photo", mine.id)
      }.not_to change { ActiveStorage::Attachment.exists?(mine.id) }.from(true)
    end
  end
end
