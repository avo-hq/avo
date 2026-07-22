require "rails_helper"

RSpec.describe "Resource#get_external_link" do
  # A record that behaves like an API-backed / non-ActiveRecord record: it has
  # data but reports `persisted? => false`. The old guard (`return unless
  # record&.persisted?`) hid the external link for these entirely.
  let(:record) { Struct.new(:id) { def persisted? = false }.new(1) }

  def resource_for(view)
    Avo::Resources::Post.new(record: record, view: view).tap do |resource|
      resource.external_link = -> { "/external/#{record.id}" }
    end
  end

  it "renders for a non-persisted (non-ActiveRecord) record on show" do
    expect(resource_for(:show).get_external_link).to eq "/external/1"
  end

  it "renders on edit" do
    expect(resource_for(:edit).get_external_link).to eq "/external/1"
  end

  it "is hidden on the new form" do
    expect(resource_for(:new).get_external_link).to be_nil
  end

  it "is hidden on the create form" do
    expect(resource_for(:create).get_external_link).to be_nil
  end

  it "is hidden when there is no record" do
    resource = Avo::Resources::Post.new(view: :show)
    resource.external_link = -> { "/external" }
    expect(resource.get_external_link).to be_nil
  end
end
