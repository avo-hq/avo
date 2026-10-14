require "rails_helper"

RSpec.describe Avo::Mappings do
  def field_type_exists?(type)
    Avo.field_manager.all.any? { |field| field[:name].to_s == type.to_s } ||
      Object.const_defined?("Avo::Fields::#{type.to_s.camelize}Field")
  end

  {
    "NAMES_MAPPING" => described_class::NAMES_MAPPING,
    "FIELDS_MAPPING" => described_class::FIELDS_MAPPING,
    "ASSOCIATIONS_MAPPING" => described_class::ASSOCIATIONS_MAPPING,
    "ATTACHMENTS_MAPPING" => described_class::ATTACHMENTS_MAPPING
  }.each do |mapping_name, mapping|
    it "maps #{mapping_name} only to field types that exist" do
      missing = mapping.select { |_, config| !field_type_exists?(config[:field]) }

      expect(missing).to be_empty
    end
  end
end
