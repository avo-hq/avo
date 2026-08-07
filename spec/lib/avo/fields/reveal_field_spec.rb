require "rails_helper"

RSpec.describe Avo::Fields::RevealField do
  subject(:field) { described_class.new(:api_token, mask_length: 6) }

  it "is hidden on forms and visible on display views" do
    expect(field.show_on_index).to be(true)
    expect(field.show_on_show).to be(true)
    expect(field.show_on_new).to be(false)
    expect(field.show_on_edit).to be(false)
  end

  it "builds a fixed-length mask" do
    expect(field.mask).to eq("••••••")
  end

  it "Base64-encodes the value for the client payload" do
    allow(field).to receive(:value).and_return("secret")

    expect(field.encoded_value).to eq(Base64.strict_encode64("secret"))
  end

  it "returns nil encoded value when the value is nil" do
    allow(field).to receive(:value).and_return(nil)

    expect(field.encoded_value).to be_nil
  end
end
