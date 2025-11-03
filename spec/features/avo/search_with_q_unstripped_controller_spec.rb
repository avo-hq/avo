# frozen_string_literal: true

require "rails_helper"

RSpec.feature Avo::SearchController, type: :controller do
  describe "searching within association" do
    let(:link) { create :course_link }
    let(:course) { create :course, links: [link] }
    let(:q) { " query text " }

    it "'q' is passed to resource search" do
      expect(TestBuddy).to receive(:hi).with("params[:q]: '#{q}', q: '#{q.strip}'").at_least :once

      get :show, params: {
        resource_name: "course_links",
        via_association: "has_many",
        via_association_id: "links",
        via_reflection_class: "Course",
        via_reflection_id: course.to_param,
        via_reflection_view: "show",
        q:,
        global: false
      }
    end
  end
end
