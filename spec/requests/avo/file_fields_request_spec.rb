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
  let(:post_record) { Post.create!(name: "Hello", body: "World", user: admin_user) }

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

  # Nothing else changes, so the record's save is the only thing that persists the new file
  it "adds a new file to the persisted ones on an edit that changes nothing else" do
    project.files.attach(
      io: File.open(Rails.root.join("db/seed_files/dummy-image.jpg")),
      filename: "persisted.jpg",
      content_type: "image/jpeg"
    )

    put "/admin/resources/projects/#{project.to_param}",
      params: {project: {files: [Rack::Test::UploadedFile.new(Rails.root.join("db/seed_files/dummy-image.jpg"), "image/jpeg")]}}

    expect(response).to have_http_status :redirect
    expect(project.reload.files.count).to eq 2
  end

  describe "the edit view of a record with a single file" do
    before do
      post_record.cover.attach(
        io: File.open(Rails.root.join("db/seed_files/iphone.jpg")),
        filename: "persisted-cover.jpg",
        content_type: "image/jpeg"
      )
    end

    it "loads the record once" do
      allow(Avo::Resources::Post).to receive(:find_record).and_call_original

      get "/admin/resources/posts/#{post_record.to_param}/edit"

      expect(response).to have_http_status :ok
      expect(response.body).to include "persisted-cover.jpg"
      expect(Avo::Resources::Post).to have_received(:find_record).once
    end

    it "keeps rendering the persisted file when the record fails validation with a new one" do
      put "/admin/resources/posts/#{post_record.to_param}",
        params: {
          post: {
            name: "", # fails the presence validation
            cover: Rack::Test::UploadedFile.new(Rails.root.join("db/seed_files/dummy-image.jpg"), "image/jpeg")
          }
        },
        headers: {"Accept" => "text/vnd.turbo-stream.html"}

      expect(response).to have_http_status :ok
      expect(response.body).to include "can&#39;t be blank"
      expect(response.body).to include "persisted-cover.jpg"
      expect(response.body).not_to include "dummy-image.jpg"
    end
  end

  describe "displaying an image" do
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

  describe "the key option" do
    def upload(filename, content_type = "image/jpeg")
      Rack::Test::UploadedFile.new(Rails.root.join("db/seed_files", filename), content_type)
    end

    after do
      Avo::Resources::Post.restore_items_from_backup
      Avo::Resources::Project.restore_items_from_backup
    end

    it "stores a file under a static key" do
      Avo::Resources::Post.with_temporary_items do
        field :cover, as: :file, key: "covers/static.jpg"
      end

      put "/admin/resources/posts/#{post_record.to_param}", params: {post: {cover: upload("dummy-image.jpg")}}

      expect(response).to have_http_status :redirect
      expect(post_record.reload.cover.blob.key).to eq "covers/static.jpg"
      expect(post_record.cover.blob.filename.to_s).to eq "dummy-image.jpg"
      expect(post_record.cover.blob.content_type).to eq "image/jpeg"
    end

    it "computes the key from the record and the uploaded file" do
      Avo::Resources::Post.with_temporary_items do
        field :cover, as: :file, key: -> { "posts/#{record.to_param}/#{file.original_filename}" }
      end

      put "/admin/resources/posts/#{post_record.to_param}", params: {post: {cover: upload("dummy-image.jpg")}}

      expect(post_record.reload.cover.blob.key).to eq "posts/#{post_record.to_param}/dummy-image.jpg"
    end

    it "uses the key on a record that's being created" do
      Avo::Resources::Post.with_temporary_items do
        field :name, as: :text
        field :cover, as: :file, key: -> { "posts/#{record.name.parameterize}/#{file.original_filename}" }
      end

      post "/admin/resources/posts", params: {post: {name: "Launch day", cover: upload("dummy-image.jpg")}}

      expect(Post.find_by!(name: "Launch day").cover.blob.key).to eq "posts/launch-day/dummy-image.jpg"
    end

    it "computes a key for each file of a files field" do
      Avo::Resources::Project.with_temporary_items do
        field :files, as: :files, key: -> { "projects/#{record.to_param}/#{file.original_filename}" }
      end

      put "/admin/resources/projects/#{project.to_param}",
        params: {project: {files: [upload("dummy-image.jpg"), upload("iphone.jpg")]}}

      expect(response).to have_http_status :redirect
      expect(project.reload.files.blobs.map(&:key)).to contain_exactly(
        "projects/#{project.to_param}/dummy-image.jpg",
        "projects/#{project.to_param}/iphone.jpg"
      )
    end

    it "falls back to a random key when the block returns nothing" do
      Avo::Resources::Post.with_temporary_items do
        field :cover, as: :file, key: -> {}
      end

      put "/admin/resources/posts/#{post_record.to_param}", params: {post: {cover: upload("dummy-image.jpg")}}

      expect(post_record.reload.cover.blob.key).to match(/\A[a-z0-9]{28}\z/)
    end

    it "shows a taken key on the field and keeps the file that holds it" do
      Avo::Resources::Post.with_temporary_items do
        field :cover, as: :file, key: -> { "posts/#{record.to_param}/#{file.original_filename}" }
      end
      put "/admin/resources/posts/#{post_record.to_param}", params: {post: {cover: upload("dummy-image.jpg")}}
      first_blob = post_record.reload.cover.blob

      put "/admin/resources/posts/#{post_record.to_param}", params: {post: {cover: upload("dummy-image.jpg")}}

      expect(response).to have_http_status 422
      expect(response.body).to include "has already been taken"
      expect(post_record.reload.cover.blob).to eq first_blob
    end

    it "refuses two files of one upload that would share a key" do
      Avo::Resources::Project.with_temporary_items do
        field :files, as: :files, key: -> { "projects/#{record.to_param}/same.jpg" }
      end

      put "/admin/resources/projects/#{project.to_param}",
        params: {project: {files: [upload("dummy-image.jpg"), upload("iphone.jpg")]}}

      expect(response).to have_http_status 422
      expect(response.body).to include "has already been taken"
      expect(project.reload.files).to be_empty
    end

    it "keeps the key of a blob that's already stored, like a direct upload" do
      blob = ActiveStorage::Blob.create_and_upload!(
        io: File.open(Rails.root.join("db/seed_files/dummy-image.jpg")),
        filename: "direct.jpg",
        content_type: "image/jpeg"
      )
      Avo::Resources::Post.with_temporary_items do
        field :cover, as: :file, key: "covers/static.jpg"
      end

      put "/admin/resources/posts/#{post_record.to_param}", params: {post: {cover: blob.signed_id}}

      expect(post_record.reload.cover.blob).to eq blob
      expect(blob.reload.key).not_to eq "covers/static.jpg"
    end

    it "hands update_using the uploaded file" do
      Avo::Resources::Post.with_temporary_items do
        field :cover,
          as: :file,
          key: -> { "covers/#{file.original_filename}" },
          update_using: -> {
            value.original_filename = "renamed.jpg"
            value
          }
      end

      put "/admin/resources/posts/#{post_record.to_param}", params: {post: {cover: upload("dummy-image.jpg")}}

      expect(post_record.reload.cover.blob.key).to eq "covers/renamed.jpg"
      expect(post_record.cover.blob.filename.to_s).to eq "renamed.jpg"
    end
  end
end
