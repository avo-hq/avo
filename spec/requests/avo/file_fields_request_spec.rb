require "rails_helper"

RSpec.describe "File fields", type: :request do
  let(:admin_user) do
    User.create!(
      first_name: "Admin",
      last_name: "User",
      email: "admin@example.com",
      password: "password",
      roles: {"admin" => true}
    )
  end

  let(:project) { Project.create!(name: "Repro", users_required: 10) }

  before { sign_in admin_user }

  # AVO-1741: the newly picked files are only in memory after a failed save, so
  # their blobs have no signed_id and every URL built from them used to raise.
  it "re-renders the edit view when the record fails validation with a new file" do
    put "/admin/resources/projects/#{project.to_param}",
      params: {
        project: {
          name: "", # fails the presence validation
          files: [Rack::Test::UploadedFile.new(Rails.root.join("db/seed_files/dummy-image.jpg"), "image/jpeg")]
        }
      },
      headers: {"Accept" => "text/vnd.turbo-stream.html"}

    expect(response).to have_http_status :ok
    expect(response.body).to include "can&#39;t be blank"
    expect(project.reload.files).to be_empty
  end

  it "keeps rendering the already persisted files" do
    project.files.attach(
      io: File.open(Rails.root.join("db/seed_files/dummy-image.jpg")),
      filename: "persisted.jpg",
      content_type: "image/jpeg"
    )

    put "/admin/resources/projects/#{project.to_param}",
      params: {
        project: {
          name: "",
          files: [Rack::Test::UploadedFile.new(Rails.root.join("db/seed_files/dummy-image.jpg"), "image/jpeg")]
        }
      },
      headers: {"Accept" => "text/vnd.turbo-stream.html"}

    expect(response).to have_http_status :ok
    expect(response.body).to include "persisted.jpg"
  end

  describe "displaying an image" do
    let(:post_record) { Post.create!(name: "Hello", body: "World", user: admin_user) }

    def attach_cover(filename)
      post_record.cover.attach(
        io: File.open(Rails.root.join("db/seed_files", filename)),
        filename: filename
      )
    end

    # Chrome, Edge and Firefox don't decode HEIC, so the original is a broken
    # image everywhere but Safari. ActiveStorage renders the variant as PNG.
    it "serves a variant for an image the browser can't paint" do
      attach_cover "dummy-image.heic"

      expect(post_record.cover.content_type).to eq "image/heic"

      get "/admin/resources/posts/#{post_record.to_param}"

      expect(response.body).to include "/rails/active_storage/representations/"
    end

    it "serves the original for a web image" do
      attach_cover "dummy-image.jpg"

      get "/admin/resources/posts/#{post_record.to_param}"

      expect(response.body).to include "/rails/active_storage/blobs/"
      expect(response.body).not_to include "/rails/active_storage/representations/"
    end

    # AVIF is in no Rails release's `web_image_content_types`, yet every current
    # browser paints it. Converting it would break apps with no image processor.
    it "serves the original for an image Rails doesn't call a web image" do
      attach_cover "dummy-image.avif"

      expect(post_record.cover.content_type).to eq "image/avif"
      expect(ActiveStorage.web_image_content_types).not_to include "image/avif"

      get "/admin/resources/posts/#{post_record.to_param}"

      expect(response.body).to include "/rails/active_storage/blobs/"
      expect(response.body).not_to include "/rails/active_storage/representations/"
    end
  end
end
