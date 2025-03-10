# frozen_string_literal: true

require "rails_helper"

RSpec.feature Avo::SearchController, type: :controller do
  let!(:course_without_links) { create :course }

  it "returns nothing when parent dont have children" do
    get :show, params: {
      resource_name: "course_links",
      via_association: "has_many",
      via_association_id: "links",
      via_reflection_class: "Course",
      via_reflection_id: course_without_links.id
    }

    expect(json["course links"]["results"].count).to eq 0
  end

  let!(:three_links) { create_list :course_link, 3 }
  let!(:course_with_three_links) { create :course, links: three_links }

  it "returns the exact three records when parent have three children" do
    get :show, params: {
      resource_name: "course_links",
      via_association: "has_many",
      via_association_id: "links",
      via_reflection_class: "Course",
      via_reflection_id: course_with_three_links.to_param
    }

    expect(json["course links"]["results"].count).to eq 3

    3.times do |index|
      expect(json["course links"]["results"][index]["_id"]).to eq course_with_three_links.links[index].to_param
    end
  end

  let!(:five_links) { create_list :course_link, 5 }
  let!(:course_with_five_links) { create :course, links: five_links }

  it "returns the exact five records when parent have five children" do
    get :show, params: {
      resource_name: "course_links",
      via_association: "has_many",
      via_association_id: "links",
      via_reflection_class: "Course",
      via_reflection_id: course_with_five_links.to_param
    }

    expect(json["course links"]["results"].count).to eq 5

    5.times do |index|
      expect(json["course links"]["results"][index]["_id"]).to eq course_with_five_links.links[index].to_param
    end
  end
end
