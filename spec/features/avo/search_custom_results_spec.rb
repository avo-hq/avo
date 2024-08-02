# frozen_string_literal: true

require "rails_helper"

RSpec.feature Avo::SearchController, type: :controller do
  let!(:project) { create :project }

  it "active record search" do
    get :show, params: {
      resource_name: "projects"
    }

    expect(json["projects"]["results"].count).to eq 1
  end

  it "custom search" do
    old_query = Avo::Resources::Project.search[:query]

    limit = 8 # default
    total_results = 9

    Avo::Resources::Project.search[:query] = -> do
      array = []

      total_results.times do |iteration|
        array << {
          _id: iteration,
          _label: "Label nr #{iteration}",
          _url: "www.#{iteration}.ro"
        }
      end

      array
    end

    get :show, params: {
      resource_name: "projects"
    }

    expect(json["projects"]["results"].count).to eq limit

    limit.times do |index|
      expect(json["projects"]["results"][index]).to eq({
        "_id" => index,
        "_label" => "Label nr #{index}",
        "_url" => "www.#{index}.ro"
      })
    end

    Avo::Resources::Project.search[:query] = old_query
  end
end
