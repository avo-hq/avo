require "rails_helper"

# Abstract resources for HasBulkUpdate testing. Marked abstract so the resource manager
# doesn't try to enumerate them as registered resources (same convention as
# namespaced_resources_spec.rb).
class ::Avo::Resources::BulkUpdateTestBase < ::Avo::BaseResource
  abstract_resource!
  self.model_class = "User"
end

class ::Avo::Resources::BulkUpdateTestChild < ::Avo::Resources::BulkUpdateTestBase
  abstract_resource!
end

RSpec.describe "Avo::Concerns::HasBulkUpdate" do
  describe "self.bulk_update DSL" do
    it "is disabled by default when nothing is set" do
      resource = ::Avo::Resources::BulkUpdateTestBase.new
      expect(resource.bulk_update_enabled?).to eq false
      expect(resource.bulk_update_fields).to eq []
      expect(resource.bulk_update_except).to eq []
      expect(resource.bulk_update_change_summary).to eq true # default
      expect(resource.handle_bulk_update_callable).to be_nil
    end

    it "returns the configured fields when set" do
      with_bulk_update(::Avo::Resources::BulkUpdateTestBase, {enabled: true, fields: [:stage, :priority]}) do
        resource = ::Avo::Resources::BulkUpdateTestBase.new
        expect(resource.bulk_update_enabled?).to eq true
        expect(resource.bulk_update_fields).to eq [:stage, :priority]
      end
    end

    it "honors change_summary: false" do
      with_bulk_update(::Avo::Resources::BulkUpdateTestBase, {enabled: true, change_summary: false}) do
        resource = ::Avo::Resources::BulkUpdateTestBase.new
        expect(resource.bulk_update_change_summary).to eq false
      end
    end

    it "falls back to Avo.configuration.bulk_update_max_records when the resource doesn't override" do
      with_bulk_update(::Avo::Resources::BulkUpdateTestBase, {enabled: true}) do
        resource = ::Avo::Resources::BulkUpdateTestBase.new
        expect(resource.bulk_update_max_records).to eq Avo.configuration.bulk_update_max_records
        expect(resource.bulk_update_max_records).to eq 500 # documented default
      end
    end

    it "lets the resource override max_records via the DSL" do
      with_bulk_update(::Avo::Resources::BulkUpdateTestBase, {enabled: true, max_records: 1_000}) do
        resource = ::Avo::Resources::BulkUpdateTestBase.new
        expect(resource.bulk_update_max_records).to eq 1_000
      end
    end

    it "falls back to Avo.configuration.bulk_update_sample_threshold" do
      with_bulk_update(::Avo::Resources::BulkUpdateTestBase, {enabled: true}) do
        resource = ::Avo::Resources::BulkUpdateTestBase.new
        expect(resource.bulk_update_sample_threshold).to eq Avo.configuration.bulk_update_sample_threshold
        expect(resource.bulk_update_sample_threshold).to eq 5
      end
    end
  end

  describe "subclass isolation (no Hash-default leak)" do
    it "does not leak parent's bulk_update to subclass and vice versa" do
      with_bulk_update(::Avo::Resources::BulkUpdateTestBase, {enabled: true, fields: [:a]}) do
        with_bulk_update(::Avo::Resources::BulkUpdateTestChild, {enabled: true, fields: [:x]}) do
          parent_resource = ::Avo::Resources::BulkUpdateTestBase.new
          child_resource = ::Avo::Resources::BulkUpdateTestChild.new
          expect(parent_resource.bulk_update_fields).to eq [:a]
          expect(child_resource.bulk_update_fields).to eq [:x]
        end
      end
    end

    it "returns a dup so in-place mutation cannot leak across instances" do
      with_bulk_update(::Avo::Resources::BulkUpdateTestBase, {enabled: true, fields: [:a]}) do
        resource = ::Avo::Resources::BulkUpdateTestBase.new
        fields = resource.bulk_update_fields
        fields << :evil
        expect(resource.bulk_update_fields).to eq [:a]
      end
    end
  end

  describe "handle_bulk_update_callable validation" do
    it "returns nil when no override is set" do
      with_bulk_update(::Avo::Resources::BulkUpdateTestBase, {enabled: true}) do
        resource = ::Avo::Resources::BulkUpdateTestBase.new
        expect(resource.handle_bulk_update_callable).to be_nil
      end
    end

    it "accepts a lambda" do
      lambda_target = ->(records:, attributes:, current_user:) {}
      with_bulk_update(::Avo::Resources::BulkUpdateTestBase, {enabled: true, handle_bulk_update: lambda_target}) do
        resource = ::Avo::Resources::BulkUpdateTestBase.new
        expect(resource.handle_bulk_update_callable).to eq lambda_target
      end
    end

    it "accepts a Proc" do
      proc_target = proc { |records:, attributes:, current_user:| }
      with_bulk_update(::Avo::Resources::BulkUpdateTestBase, {enabled: true, handle_bulk_update: proc_target}) do
        resource = ::Avo::Resources::BulkUpdateTestBase.new
        expect(resource.handle_bulk_update_callable).to eq proc_target
      end
    end

    it "raises ArgumentError when a Symbol is assigned (the silent-no-op footgun)" do
      with_bulk_update(::Avo::Resources::BulkUpdateTestBase, {enabled: true, handle_bulk_update: :my_method}) do
        resource = ::Avo::Resources::BulkUpdateTestBase.new
        expect { resource.handle_bulk_update_callable }.to raise_error(ArgumentError, /must be a Proc, lambda, or Method/)
      end
    end

    it "raises ArgumentError when a String is assigned" do
      with_bulk_update(::Avo::Resources::BulkUpdateTestBase, {enabled: true, handle_bulk_update: "not callable"}) do
        resource = ::Avo::Resources::BulkUpdateTestBase.new
        expect { resource.handle_bulk_update_callable }.to raise_error(ArgumentError)
      end
    end
  end

  describe "AUTO_EXCLUDED_FIELD_TYPES" do
    it "names the field types that don't bulk-edit safely" do
      expect(Avo::Concerns::HasBulkUpdate::AUTO_EXCLUDED_FIELD_TYPES).to include("file", "has_many", "has_and_belongs_to_many", "key_value", "password")
    end
  end

  # Helper to set self.bulk_update on a resource class during a test and restore afterward.
  # Avoids leaking state across examples (the class_attribute is shared at the class level).
  def with_bulk_update(resource_class, config)
    original = resource_class.bulk_update
    resource_class.bulk_update = config
    yield
  ensure
    resource_class.bulk_update = original
  end
end
