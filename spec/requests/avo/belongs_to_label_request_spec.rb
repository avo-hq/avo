require "rails_helper"

# The label used to point at "#{field_id}_id" while the select was named after the
# foreign key, so a field whose name differs from its foreign key got a label that
# targets nothing (avo-hq/avo#4877). Person has `belongs_to :another_person,
# foreign_key: :person_id`.
RSpec.describe "Belongs to field label", type: :request do
  let(:admin_user) { create :user, roles: {admin: true} }

  before { login_as admin_user }

  it "points the label at the select when the field name differs from the foreign key" do
    get "/admin/resources/people/new"

    doc = Capybara.string(response.body)
    label = doc.find("label", text: "Another person")

    expect(doc).to have_css("select##{label[:for]}")
  end
end
