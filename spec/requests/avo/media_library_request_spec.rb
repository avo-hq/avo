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
    expect(response.body).to include("media-library-details__preview-image")
    expect(response.body).to include("/rails/active_storage/representations/redirect/")
    expect(response.body).to include("attachment.jpg")
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

  it "allows metadata-only updates when filename is omitted" do
    blob = create_image_blob(filename: "keep.jpg")
    blob.update_column(:metadata, {"identified" => true, "width" => 120, "height" => 80})

    patch "/admin/media-library/#{blob.id}", params: {blob: {metadata: {title: "Hello"}}}

    expect(response).to redirect_to("/admin/media-library/#{blob.id}/edit")
    expect(flash[:error]).to be_nil

    blob.reload
    expect(blob.filename.to_s).to eq("keep.jpg")
    expect(blob.metadata["width"]).to eq(120)
    expect(blob.metadata["title"]).to eq("Hello")
  end

  it "renders the index grid even when a listed blob has a blank filename" do
    broken = create_image_blob
    broken.update_column(:filename, "")

    get "/admin/media-library"

    expect(response).to have_http_status(:ok)
    expect(response.body).to include(ActionView::RecordIdentifier.dom_id(broken))
    expect(response.body).to include("media-library__item-thumbnail-image")
    expect(response.body).to include("/rails/active_storage/representations/redirect/")
    expect(response.body).to include("attachment.jpg")
  end

  # AVO-1416: the attach modal has to be wide enough for the media grid.
  it "renders the attach modal at the wide size" do
    get "/admin/attach-media", headers: {"Turbo-Frame" => Avo::MODAL_FRAME_ID.to_s}

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("modal--width-5xl")
  end

  it "exposes routable blob URLs in attach mode when a listed blob has a blank filename" do
    broken = create_image_blob
    broken.update_column(:filename, "")

    get "/admin/attach-media"

    expect(response).to have_http_status(:ok)
    expect(response.body).to include(ActionView::RecordIdentifier.dom_id(broken))
    expect(response.body).to include('data-media-library-path-param="/rails/active_storage/blobs/redirect/')
    expect(response.body).to include('data-media-library-url-param="http')
    expect(response.body).to include("attachment.jpg")
  end

  describe "access control" do
    # `visible` is the per-user gate for the whole feature. Before this was
    # enforced, a block returning false hid the sidebar item and left every
    # route reachable by URL to any authenticated Avo user.
    def with_visible(value)
      previous = Avo::MediaLibrary.configuration.visible
      Avo::MediaLibrary.configuration.visible = value
      yield
    ensure
      Avo::MediaLibrary.configuration.visible = previous
    end

    # `raise_404` raises rather than rendering, the same way a disabled media
    # library already does; Rails turns it into a 404 in production.
    def expect_refused
      expect { yield }.to raise_error(ActionController::RoutingError)
    end

    it "refuses to list blobs when the library is not visible to the user" do
      create_blob

      with_visible(-> { false }) do
        expect_refused { get "/admin/media-library" }
      end
    end

    it "refuses the attach picker when the library is not visible to the user" do
      create_blob

      with_visible(-> { false }) do
        expect_refused { get "/admin/attach-media" }
      end
    end

    it "refuses to show a blob when the library is not visible to the user" do
      blob = create_blob

      with_visible(-> { false }) do
        expect_refused { get "/admin/media-library/#{blob.id}" }
      end
    end

    it "refuses to open the edit page when the library is not visible to the user" do
      blob = create_blob(filename: "secret.txt")

      with_visible(-> { false }) do
        expect_refused { get "/admin/media-library/#{blob.id}/edit" }
      end
    end

    it "refuses to rename a blob when the library is not visible to the user" do
      blob = create_blob(filename: "original.txt")

      with_visible(-> { false }) do
        expect_refused { patch "/admin/media-library/#{blob.id}", params: {blob: {filename: "renamed.txt"}} }
      end

      expect(blob.reload.filename.to_s).to eq("original.txt")
    end

    it "refuses to destroy a blob when the library is not visible to the user" do
      blob = create_blob

      with_visible(-> { false }) do
        expect {
          expect_refused { delete "/admin/media-library/#{blob.id}" }
        }.not_to change { ActiveStorage::Blob.exists?(blob.id) }.from(true)
      end
    end

    it "evaluates the block per request against the current user" do
      create_blob

      # False for anyone signed in -- proves the block is both evaluated with
      # user context and actually enforced, not just consulted for the menu.
      with_visible(-> { Avo::Current.user.blank? }) do
        expect_refused { get "/admin/media-library" }
      end
    end

    it "still allows every action when the library is visible" do
      blob = create_blob(filename: "original.txt")

      with_visible(-> { true }) do
        get "/admin/media-library"
        expect(response).to have_http_status(:ok)

        get "/admin/media-library/#{blob.id}/edit"
        expect(response).to have_http_status(:ok)

        patch "/admin/media-library/#{blob.id}", params: {blob: {filename: "renamed.txt"}}
        expect(blob.reload.filename.to_s).to eq("renamed.txt")

        expect {
          delete "/admin/media-library/#{blob.id}"
        }.to change { ActiveStorage::Blob.exists?(blob.id) }.from(true).to(false)
      end
    end
  end
end
