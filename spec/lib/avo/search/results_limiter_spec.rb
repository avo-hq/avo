# frozen_string_literal: true

require "rails_helper"

RSpec.describe Avo::Search::ResultsLimiter do
  describe ".apply" do
    context "with an Array" do
      it "returns the array unchanged" do
        array = [{_label: "a"}, {_label: "b"}, {_label: "c"}]

        expect(described_class.apply(array)).to eq(array)
      end
    end

    context "with an ActiveRecord relation" do
      before do
        10.times { |i| create(:user, first_name: "LimitUser#{i}") }
      end

      it "applies the default limit when the relation has no user limit" do
        query = User.where("first_name LIKE ?", "LimitUser%")

        result = described_class.apply(query)

        expect(result.limit_value).to eq(Avo.configuration.search_results_count)
        expect(result.count).to eq(Avo.configuration.search_results_count)
      end

      it "keeps the user limit when one is already applied" do
        query = User.where("first_name LIKE ?", "LimitUser%").limit(20)

        result = described_class.apply(query)

        expect(result.limit_value).to eq(20)
        expect(result.count).to eq(10)
      end
    end

    context "with a model class" do
      it "coerces to a relation and applies the default limit" do
        3.times { |i| create(:user, first_name: "ClassLimit#{i}") }

        allow(Avo.configuration).to receive(:search_results_count).and_return(2)

        result = described_class.apply(User)

        expect(result.limit_value).to eq(2)
      end
    end
  end
end
