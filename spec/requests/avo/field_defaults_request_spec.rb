require "rails_helper"

# The fish form declares an `id` number field without help, and a `name` text
# field with its own `help: "help text"`. With `config.field_defaults` set, the
# number field picks up the default help and the text field keeps its own.
RSpec.describe "Field defaults", type: :request do
  let(:admin_user) { create :user, roles: {admin: true} }

  around do |example|
    original = Avo.configuration.field_defaults
    example.run
    Avo.configuration.field_defaults = original
  end

  before do
    login_as admin_user

    Avo.configuration.field_defaults = {
      number: {help: "Number help from the app defaults"},
      text: {help: "Text help from the app defaults"}
    }
  end

  it "renders the defaults on fields that don't set the option" do
    get "/admin/resources/fish/new"

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Number help from the app defaults")
  end

  it "keeps the field's own option" do
    get "/admin/resources/fish/new"

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("help text")
    expect(response.body).not_to include("Text help from the app defaults")
  end
end
