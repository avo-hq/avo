require "rails_helper"

# Shift+T focuses the screen's main content via a single `data-content-focus`
# anchor. These request specs assert the anchor is rendered (and correctly placed)
# on each screen; the system spec covers the actual focus behaviour in the browser.
RSpec.describe "Shift+T content focus anchor", type: :request do
  let(:admin_user) { create :user, roles: {admin: true} }

  before { login_as admin_user }

  it "marks the index table as the content-focus anchor" do
    create_list(:project, 2)

    get "/admin/resources/projects"

    expect(response.body).to include('data-content-focus=""')
    expect(response.body).to match(/<table[^>]*data-index-row-navigator-target="table"/)
  end

  it "marks the grid wrapper as the content-focus anchor on grid index" do
    create_list(:user, 2)

    get "/admin/resources/users?view_type=grid"

    expect(response.body).to match(/class="grid-wrapper"[^>]*tabindex="-1"[^>]*data-content-focus/m)
  end

  it "marks the panel body as the content-focus anchor on show" do
    project = create(:project)

    get "/admin/resources/projects/#{project.id}"

    expect(response.body).to match(/class="panel__body" data-content-focus tabindex=-1/)
  end

  it "marks the panel body as the content-focus anchor on edit" do
    project = create(:project)

    get "/admin/resources/projects/#{project.id}/edit"

    expect(response.body).to match(/class="panel__body" data-content-focus tabindex=-1/)
  end

  it "marks the media library grid as the content-focus anchor on the standalone library" do
    get "/admin/media-library"

    expect(response.body).to match(/class="media-library__grid[^"]*"[^>]*tabindex="-1"[^>]*data-content-focus/m)
  end

  it "does not mark the media library grid as an anchor in attach mode" do
    get "/admin/attach-media"

    # The grid still renders in attach mode...
    expect(response.body).to include("media-library__grid")
    # ...but the host form owns the page's Shift+T anchor, so the embedded
    # library grid must not advertise itself as a second one.
    expect(response.body).not_to match(/media-library__grid[^>]*data-content-focus/m)
  end

  it "marks the panel body as the content-focus anchor on a media library blob edit" do
    blob = ActiveStorage::Blob.create_and_upload!(
      io: StringIO.new("hello"),
      filename: "hello.txt",
      content_type: "text/plain"
    )

    get "/admin/media-library/#{blob.id}/edit"

    expect(response.body).to match(/class="panel__body" data-content-focus tabindex=-1/)
  end

  it "redirects a media library blob show to its edit page" do
    blob = ActiveStorage::Blob.create_and_upload!(
      io: StringIO.new("hello"),
      filename: "hello.txt",
      content_type: "text/plain"
    )

    get "/admin/media-library/#{blob.id}"

    expect(response).to redirect_to("/admin/media-library/#{blob.id}/edit")
  end

  it "does not mark a has-many table on a show view as a content-focus anchor" do
    project = create(:project)
    create(:comment, commentable: project)

    get "/admin/resources/projects/#{project.id}"

    # The associated table must not advertise itself as a global Shift+T target.
    expect(response.body).not_to match(/data-index-row-navigator-target="table"[^>]*data-content-focus/)
  end
end
