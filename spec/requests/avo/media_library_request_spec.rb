require "rails_helper"

RSpec.describe "Media library edit", type: :request do
  let(:admin_user) { create :user, roles: {admin: true} }

  before { login_as admin_user }

  def create_blob(filename: "hello.txt")
    ActiveStorage::Blob.create_and_upload!(
      io: StringIO.new("hello"),
      filename: filename,
      content_type: "text/plain"
    )
  end

  def create_image_blob(filename: "dummy-image.jpg")
    ActiveStorage::Blob.create_and_upload!(
      io: Avo::Engine.root.join("spec", "dummy", "db", "seed_files", "dummy-image.jpg").open,
      filename: filename,
      content_type: "image/jpeg"
    )
  end

  it "pre-fills the filename field so saving can't blank it" do
    blob = create_blob(filename: "report.pdf")

    get "/admin/media-library/#{blob.id}/edit"

    expect(response).to have_http_status(:ok)
    expect(response.body).to include('value="report.pdf"')
  end

  it "renders the edit page for an image blob with a blank filename instead of raising" do
    # Exact repro of blob #28: an image (so the preview reaches `.variant`)
    # whose filename was wiped, which 500'd on every representation url_for.
    blob = create_image_blob
    blob.update_column(:filename, "")

    get "/admin/media-library/#{blob.id}/edit"

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("media-library-details__preview-placeholder")
  end

  it "refuses to blank the filename on update (keeps the blob intact)" do
    blob = create_image_blob(filename: "keep.jpg")

    patch "/admin/media-library/#{blob.id}", params: {blob: {filename: "", metadata: {title: "T"}}}

    expect(response).to redirect_to("/admin/media-library/#{blob.id}/edit")
    expect(blob.reload.filename.to_s).to eq("keep.jpg")
  end

  it "preserves system metadata (width/height) when editing title/alt/description" do
    blob = create_image_blob(filename: "keep.jpg")
    blob.update_column(:metadata, {"identified" => true, "width" => 120, "height" => 80})

    patch "/admin/media-library/#{blob.id}", params: {blob: {filename: "keep.jpg", metadata: {title: "Hello"}}}

    blob.reload
    expect(blob.metadata["width"]).to eq(120)
    expect(blob.metadata["title"]).to eq("Hello")
  end

  it "renders the index grid even when a listed blob has a blank filename" do
    good = create_image_blob(filename: "good.jpg")
    broken = create_image_blob
    broken.update_column(:filename, "")

    get "/admin/media-library"

    expect(response).to have_http_status(:ok)
    # The broken blob falls back to the thumbnail placeholder instead of 500ing.
    expect(response.body).to include(ActionView::RecordIdentifier.dom_id(broken))
    expect(response.body).to include("media-library__item-thumbnail-placeholder")
  end
end
