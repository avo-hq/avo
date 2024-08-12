# frozen_string_literal: true

require "rails_helper"

RSpec.describe "DefaultSortColumnAndDirection", type: :feature do
  context "default_sort_column and default_sort_direction" do
    let(:courses) do
      create_list(:course, 3) do |course, i|
        course.update(created_at: (i + 1).days.ago)
      end
    end
    let(:course_index) { "/admin/resources/courses" }
    let(:default_sort_column) { :created_at }
    let(:default_sort_direction) { Avo::Resources::Base.default_sort_direction }

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
      Avo::Resources::Course.default_sort_direction = default_sort_direction
    end

    shared_examples "sorts by" do |expected_sort_column, expected_sort_direction|
      it "sorts index table by #{expected_sort_column} in #{expected_sort_direction || "desc"}" do
        sorted_values = courses.sort_by(&expected_sort_column).map do |course|
          value = course.send(expected_sort_column)
          value.is_a?(Time) ? value.iso8601 : value
        end
        unless expected_sort_direction == :asc
          sorted_values.reverse!
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

    context "when default_sort_direction is set to asc" do
      let(:default_sort_column) { :country }
      let(:default_sort_direction) { :asc }

      include_examples "sorts by", :country, :asc
    end

    context "when default_sort_direction is set to desc" do
      let(:default_sort_column) { :country }
      let(:default_sort_direction) { :desc }

      include_examples "sorts by", :country, :desc
    end

    context "when default_sort_direction is not set" do
      let(:default_sort_column) { :country }

      include_examples "sorts by", :country, :desc
    end
  end
end
