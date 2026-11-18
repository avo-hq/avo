require "rails_helper"

# With deprecation warnings on, Ruby 3.4+ warns when code appends to a string literal; frozen-by-default literals
# will raise FrozenError. The keys must not change either, or an upgrade forgets every remembered filter and sort.
RSpec.describe "Session keys for remembered filters and sorting" do
  let(:controller) do
    Class.new do
      include Avo::Concerns::FiltersSessionHandler
      include Avo::Concerns::SortingSessionHandler

      def params = {"controller" => "avo/resources", "resource_name" => "users", "action" => "index"}
    end.new
  end

  around do |example|
    deprecated = Warning[:deprecated]
    Warning[:deprecated] = true
    example.run
  ensure
    Warning[:deprecated] = deprecated
  end

  it "builds them without appending to a string literal" do
    expect {
      expect(controller.filters_session_key).to eq "/encoded_filters/avo/resources/users/index"
      expect(controller.sorting_session_key).to eq "/sorting/avo/resources/users/index"
    }.not_to output(/literal string will be frozen/).to_stderr
  end
end
