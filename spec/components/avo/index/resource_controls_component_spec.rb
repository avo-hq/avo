require "rails_helper"

# `can_detach?` renders the detach control only for collection associations, and
# it decides that through `is_has_many_association?`. Rails uses the same
# `ThroughReflection` class for `has_many :through` and `has_one :through`, so
# the class alone can't tell them apart — `collection?` is what separates them.
RSpec.describe Avo::Index::ResourceControlsComponent, type: :component do
  let(:user) { User.create!(first_name: "Adrian", last_name: "Marin", email: "adrian@example.com", password: "secret123") }
  let(:resource) { Avo::Resources::User.new(record: user, view: Avo::ViewInquirer.new("index")) }

  def build_component(reflection:)
    described_class.new(
      resource: resource,
      reflection: reflection,
      parent_record: nil,
      parent_resource: nil,
      view_type: :table,
      actions: []
    )
  end

  describe "#is_has_many_association?" do
    {
      "has_many" => -> { Team.reflect_on_association(:memberships) },
      "has_many :through" => -> { Team.reflect_on_association(:team_members) },
      "has_and_belongs_to_many" => -> { User.reflect_on_association(:projects) }
    }.each do |macro, reflection|
      it "is true for #{macro}" do
        expect(build_component(reflection: reflection.call).is_has_many_association?).to be(true)
      end
    end

    {
      "has_one" => -> { Team.reflect_on_association(:admin_membership) },
      "has_one :through" => -> { Team.reflect_on_association(:admin) },
      "belongs_to" => -> { TeamMembership.reflect_on_association(:team) }
    }.each do |macro, reflection|
      it "is false for #{macro}" do
        expect(build_component(reflection: reflection.call).is_has_many_association?).to be(false)
      end
    end
  end

  describe "#can_detach?" do
    it "is false for a has_one :through, which owns a single record" do
      component = build_component(reflection: Team.reflect_on_association(:admin))

      expect(component.can_detach?).to be(false)
    end
  end
end
