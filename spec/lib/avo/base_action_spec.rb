require "rails_helper"

RSpec.describe Avo::BaseAction do
  # `reload_record` / `reload_records` may be called with no argument, in which case they reload the
  # records the action is already operating on (its `query`). This is the documented behaviour; the
  # argument used to be required, so a bare `reload_record` raised ArgumentError.
  describe "#reload_record without an argument" do
    let(:records) { [Object.new, Object.new] }
    # A double for view_type only — reload_record reads it to pick the row/grid streamer, whose body
    # is a lambda stored for later and never run here, so no real resource or records are needed.
    let(:resource) { instance_double(Avo::Resources::User, view_type: :table) }
    let(:action) { Avo::Actions::ToggleInactive.new(resource: resource, query: records) }

    it "reloads the records the action is operating on" do
      action.reload_record

      expect(action.records_to_reload).to eq(records)
    end

    it "is aliased as reload_records" do
      action.reload_records

      expect(action.records_to_reload).to eq(records)
    end
  end
end
