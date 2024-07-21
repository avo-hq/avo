# frozen_string_literal: true

require "rails_helper"

RSpec.describe "DefaultSortColumn", type: :feature do
  context "default_sort_column" do
    let(:courses) do
      create_list(:course, 3) do |course, i|
        course.update(created_at: (i + 1).days.ago)
      end
    end
    let(:course_index) { "/admin/resources/courses" }
    let(:default_sort_column) { :created_at }

    before(:all) do
      Avo::Resources::Course.with_temporary_items do
        field :id, as: :id
        field :country, as: :text
        field :created_at, as: :date_time
      end
    end

    after(:all) do
      Avo::Resources::Course.restore_items_from_backup
    end

    before do
      Avo::Resources::Course.default_sort_column = default_sort_column
    end

    shared_examples "sorts by" do |expected_sort_column|
      it "sorts index table by #{expected_sort_column} in desc" do
        sorted_values = courses.sort_by(&expected_sort_column).reverse.map do |course|
          value = course.send(expected_sort_column)
          value.is_a?(Time) ? value.iso8601 : value
        end
        visit course_index

        values = page.all("[data-field-id='#{expected_sort_column}']").map(&:text)
        expect(values).to eq(sorted_values)
      end
    end

    context "when default_sort_column is set" do
      let(:default_sort_column) { :country }

      include_examples "sorts by", :country

      context "when default_sort_column does not exist" do
        let(:default_sort_column) { :foo }

        include_examples "sorts by", :created_at
      end
    end

    context "when default_sort_column is not set" do
      let(:default_sort_column) { nil }

      include_examples "sorts by", :created_at
    end
  end
end
