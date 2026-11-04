require "rails_helper"

# Avo 3 runs on pagy 7 to 9 and on pagy 43, which changed its whole API (see Avo::PagyCompat).
RSpec.describe "Pagination", type: :request do
  let(:admin_user) { create :user, roles: {admin: true} }

  before { login_as admin_user }

  def current_page
    response.body[/aria-current="page"[^>]*>(\d+)</, 1]
  end

  it "shows the first page when the page is out of range" do
    create_list :fish, 2

    get "/admin/resources/fish", params: {page: 99, per_page: 1}

    expect(response).to have_http_status(:ok)
    expect(current_page).to eq "1"
  end

  it "shows pagy texts in the locale of the request" do
    create_list :fish, 2

    get "/admin/resources/fish", params: {force_locale: "fr", per_page: 1}

    expect(response.body).to include "Affichage des"
  end

  # Pagy 43 keeps its locale in a thread variable, which the host app's own pages read too.
  it "leaves the pagy locale of the thread as it was", if: Avo::PagyCompat.pagy_43? do
    create_list :fish, 2

    get "/admin/resources/fish", params: {force_locale: "fr", per_page: 1}

    expect(Pagy::I18n.locale).to eq "en"
  end
end
