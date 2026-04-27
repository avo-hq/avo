require "rails_helper"

RSpec.describe "EncryptedTextField", type: :feature do
  class DummyRecord
    attr_accessor :secret_token
  end

  describe "field class" do
    it "returns masked value" do
      field = Avo::Fields::EncryptedTextField.new(:secret_token)
      expect(field.masked_value).to eq("••••••••")
    end

    it "has revealable option enabled by default" do
      field = Avo::Fields::EncryptedTextField.new(:secret_token)
      expect(field.revealable).to be true
    end

    it "allows disabling revealable" do
      field = Avo::Fields::EncryptedTextField.new(:secret_token, revealable: false)
      expect(field.revealable).to be false
    end
  end

  describe "fill_field" do
    let(:record) { DummyRecord.new }
    let(:field) { Avo::Fields::EncryptedTextField.new(:secret_token) }

    before do
      field.hydrate(record: record, view: Avo::ViewInquirer.new("edit"), resource: nil)
    end

    it "skips empty values to preserve existing data" do
      record.secret_token = "existing-value"
      field.fill_field(record, :secret_token, "", {})
      expect(record.secret_token).to eq("existing-value")
    end

    it "skips nil values" do
      record.secret_token = "existing-value"
      field.fill_field(record, :secret_token, nil, {})
      expect(record.secret_token).to eq("existing-value")
    end

    it "updates when new value is provided" do
      record.secret_token = "old-value"
      field.fill_field(record, :secret_token, "new-value", {})
      expect(record.secret_token).to eq("new-value")
    end

    it "skips if value equals the mask" do
      record.secret_token = "existing-value"
      field.fill_field(record, :secret_token, "••••••••", {})
      expect(record.secret_token).to eq("existing-value")
    end
  end
end
