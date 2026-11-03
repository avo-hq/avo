require "rails_helper"

RSpec.describe Avo::Services::URIService do
  describe "#append_query" do
    def query_of(url)
      Rack::Utils.parse_nested_query(URI.parse(url).query)
    end

    it "appends simple params" do
      url = described_class.parse("/admin/resources/users").append_query({view: "index", page: 2}).to_s

      expect(url).to eq "/admin/resources/users?view=index&page=2"
    end

    it "keeps the existing query" do
      url = described_class.parse("/admin/resources/users?view_type=table").append_query({page: 2}).to_s

      expect(url).to eq "/admin/resources/users?view_type=table&page=2"
    end

    it "escapes values so they round trip" do
      params = {q: "C++ & Rust", view: "index"}

      url = described_class.parse("/admin/resources/users/1/posts").append_query(params).to_s

      expect(query_of(url)).to eq params.stringify_keys
    end

    it "keeps nested params" do
      params = {filters: {name: {contains: ["Café"]}}}

      url = described_class.parse("/admin/resources/users").append_query(params).to_s

      expect(query_of(url)).to eq params.deep_stringify_keys
    end
  end
end
