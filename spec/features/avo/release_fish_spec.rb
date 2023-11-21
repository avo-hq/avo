require 'rails_helper'

RSpec.feature Avo::Actions::ReleaseFish, type: :feature do
  let(:fish) { create :fish }
  let(:current_user) { admin }
  let(:resource) { Avo::Resources::User.new.hydrate record: fish }

  it "tests the dummy action" do
    args = {
      fields: {
        message: "Bye fishy!",
        user_id: admin.id
      }.with_indifferent_access,
      current_user: current_user,
      resource: resource,
      records: [fish]
    }

    action = described_class.new(record: fish, resource: resource, user: current_user, view: :edit)

    expect(action).to receive(:succeed).with "1 fish released with message 'Bye fishy!' by #{admin.name}."
    expect(fish).to receive(:release)

    action.handle(**args)
  end
end
