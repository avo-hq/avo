# frozen_string_literal: true

require "rails_helper"

RSpec.describe Avo::Filters::BasicFilters do
  let(:resource) { Avo::Resources::Team.new }

  def applied_for(applied_filters)
    described_class.to_be_applied(resource: resource, applied_filters: applied_filters)
  end

  describe ".to_be_applied" do
    it "keeps the filters the resource declares" do
      expect(applied_for("Avo::Filters::NameFilter" => "Avo"))
        .to include("Avo::Filters::NameFilter" => "Avo")
    end

    it "keeps the defaults of the filters the resource declares" do
      expect(applied_for({})).to include("Avo::Filters::MembersFilter" => {has_members: true})
    end

    it "drops a filter the resource no longer declares" do
      applied = applied_for(
        "Avo::Filters::NameFilter" => "Avo",
        "Avo::Filters::PublishedFilter" => true
      )

      expect(applied).to include("Avo::Filters::NameFilter" => "Avo")
      expect(applied).not_to have_key("Avo::Filters::PublishedFilter")
    end

    it "drops a filter whose class no longer exists" do
      expect(applied_for("Avo::Filters::Tickets::ByCity" => "Berlin"))
        .not_to have_key("Avo::Filters::Tickets::ByCity")
    end

    it "handles a nil applied_filters" do
      expect(applied_for(nil)).to include("Avo::Filters::MembersFilter" => {has_members: true})
    end
  end
end
