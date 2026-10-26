require "rails_helper"

# A belongs_to field's "Create new" dialog stacks in the nested frame of the modal it sits in, which only
# modal levels render. Rendered from any other frame, the link has to open the page's own modal frame.
RSpec.describe "belongs_to Create new modal frame", type: :request do
  let(:admin_user) { create :user, roles: {admin: true} }

  before { login_as admin_user }

  def create_user_link_frame
    Nokogiri::HTML(response.body).at_css("a[href*='via_relation=user']")["data-turbo-frame"]
  end

  it "opens in the page's modal frame on a full page load" do
    get "/admin/resources/fish/new"

    expect(create_user_link_frame).to eq "modal_frame"
  end

  it "opens in the page's modal frame when rendered from a frame that is not a modal level" do
    get "/admin/resources/fish/new", headers: {"Turbo-Frame" => "has_many_field_show_fish"}

    expect(create_user_link_frame).to eq "modal_frame"
  end

  it "does not treat a frame that only starts like the modal frame as a modal level" do
    get "/admin/resources/fish/new", headers: {"Turbo-Frame" => "modal_frame_other"}

    expect(create_user_link_frame).to eq "modal_frame"
  end

  it "stacks on the modal level the dialog is rendered in" do
    get "/admin/resources/posts/new",
      params: {modal_layout: true, via_belongs_to_resource_class: "Avo::Resources::Comment", via_relation: "commentable"},
      headers: {"Turbo-Frame" => "modal_frame_nested"}

    page = Nokogiri::HTML(response.body)
    expect(page.at_css("turbo-frame#modal_frame_nested")).to be_present
    expect(page.at_css("turbo-frame#modal_frame_nested turbo-frame#modal_frame_nested_nested")).to be_present
    expect(create_user_link_frame).to eq "modal_frame_nested_nested"
  end
end
