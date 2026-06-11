require "rails_helper"

RSpec.describe Avo::Concerns::HasDescription, type: :model do
  describe "association field descriptions" do
    let(:team) { create(:team) }
    let(:base_args) { {record: team, view: :show} }

    def field(**args)
      Avo::Fields::HasManyField.new(:memberships, **base_args, **args)
    end

    # Collects the SQL run while the block executes, ignoring schema/transaction/
    # cached statements, so we can assert a description path stays off the DB.
    # Building the `query` relation is lazy (no SQL); only enumerating or
    # aggregating it (e.g. `query.count`) hits the database.
    def capture_sql
      queries = []
      callback = ->(_name, _start, _finish, _id, payload) {
        queries << payload[:sql] unless payload[:name].to_s.in?(%w[SCHEMA TRANSACTION CACHE])
      }
      ActiveSupport::Notifications.subscribed(callback, "sql.active_record") { yield }
      queries
    end

    it "returns a static string without running SQL" do
      target = field(description: "Hey members")

      result = nil
      queries = capture_sql { result = target.description }

      expect(result).to eq "Hey members"
      expect(queries).to be_empty
    end

    it "returns nil without running SQL" do
      target = field(description: nil)

      result = :unset
      queries = capture_sql { result = target.description }

      expect(result).to be_nil
      expect(queries).to be_empty
    end

    it "evaluates a lambda with the association relation as query" do
      record = team
      allow(record).to receive(:memberships).and_call_original
      captured_query = nil

      result = field(description: -> {
        captured_query = query
        "#{query.klass.name} items"
      }).description

      expect(record).to have_received(:memberships)
      expect(captured_query).to eq team.memberships
      expect(result).to eq "TeamMembership items"
    end

    it "lets additional_attributes override query" do
      custom_query = double("query")
      captured_query = nil

      field(description: -> { captured_query = query }).description(query: custom_query)

      expect(captured_query).to eq custom_query
    end

    it "exposes loading_type as nil by default" do
      captured = :unset

      field(description: -> { captured = loading_type }).description

      expect(captured).to be_nil
    end

    it "exposes loading_type as :manual when the manual placeholder passes it" do
      captured = :unset

      field(description: -> { captured = loading_type }).description(loading_type: :manual)

      expect(captured).to eq :manual
    end

    it "lets a lambda branch on loading_type to skip the SQL aggregation" do
      target = field(description: -> {
        loading_type == :manual ? "Hey members" : "Hey members (#{query.count})"
      })

      result = nil
      queries = capture_sql { result = target.description(loading_type: :manual) }

      expect(result).to eq "Hey members"
      expect(queries).to be_empty
    end

    it "runs the SQL aggregation when loading_type is not :manual" do
      target = field(description: -> {
        loading_type == :manual ? "Hey members" : "Hey members (#{query.count})"
      })

      result = nil
      queries = capture_sql { result = target.description }

      expect(result).to eq "Hey members (0)"
      expect(queries).not_to be_empty
    end
  end
end
