# frozen_string_literal: true

require "rails_helper"

RSpec.feature Avo::SearchController, type: :controller do
  let!(:courses) do
    create_list(:course, 10) do |course, idx|
      course.name = "course_#{idx + 1}"
      course.save!
    end
  end

  context "When results_count is not set in the resource" do
    it "Returns 8 results by default" do
      get :show, params: {
        resource_name: "course",
        global: false,
        q: "course"
      }

      expect(json["courses"]["count"]).to eq 8
    end
  end

  context "When results_count is changed in a per resource basis" do
    after(:example) do
      Avo::Resources::Course.search[:results_count] = nil
    end

    it "Return 5 when configured" do
      Avo::Resources::Course.search[:results_count] = 5
      get :show, params: {
        resource_name: "course",
        global: false,
        q: "course"
      }

      expect(json["courses"]["count"]).to eq 5
    end

    it "Return 2 when configured" do
      Avo::Resources::Course.search[:results_count] = 2
      get :show, params: {
        resource_name: "course",
        global: false,
        q: "course"
      }

      expect(json["courses"]["count"]).to eq 2
    end

    let!(:post) { create :post, name: "Avi's masterclass" }

    it "is configurable per resource" do
      Avo::Resources::Post.search[:results_count] = 0
      get :show, params: {
        resource_name: "post",
        global: false,
        q: "class"
      }

      expect(json["posts"]["count"]).to eq 0

      res = get :show, params: {
        resource_name: "course",
        global: false,
        q: "course"
      }
      expect(JSON.parse(res.body)["courses"]["count"]).to eq 8
    end
  end
end
