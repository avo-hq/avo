require "rails_helper"

RSpec.describe Avo::UrlHelpers, type: :helper do
  before do
    ActiveSupport::Inflector.inflections(:en) do |inflect|
      inflect.acronym "URL"
    end
  end

  it "loads url_helpers without Zeitwerk errors" do
    # This will trigger Zeitwerk to autoload the file
    expect {
      Avo::UrlHelpers
    }.not_to raise_error

    expect(Avo::URLHelpers).to eq(Avo::UrlHelpers)
  end
end
