require "rails_helper"

RSpec.feature "MissingAssociationError", type: :feature do
  let!(:team) { create :team }
  let(:url) do
    "/admin/resources/teams/#{team.id}/ghosts?turbo_frame=has_many_field_show_ghosts&show_missing_association_field=1"
  end

  it "names the missing model association and its expected declaration" do
    expect {
      visit url
    }.to raise_error(Avo::MissingAssociationError).with_message(
      "Failed to find the :ghosts association on Team while rendering the :ghosts field.\n" \
      "Define `has_many :ghosts` on Team, or update the Avo field to use an association that exists.\n" \
      "More info on https://docs.avohq.io/4.0/associations.html."
    )
  end
end
