require "rails_helper"

RSpec.describe "Media library", type: :request do
  let(:admin_user) { create :user, roles: {admin: true} }

  before { login_as admin_user }

  def create_blob(filename: "hello.txt")
    ActiveStorage::Blob.create_and_upload!(
      io: StringIO.new("hello"),
      filename: filename,
      content_type: "text/plain"
    )
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
      blob = create_blob(filename: "secret.txt")

      with_visible(-> { false }) do
        expect_refused { get "/admin/media-library/#{blob.id}" }
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

        get "/admin/media-library/#{blob.id}"
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
