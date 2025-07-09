# frozen_string_literal: true

require "rails_helper"

RSpec.feature Avo::SearchController, type: :controller do
  let!(:course) { create(:course, name: "Ruby Programming") }
  let!(:course_with_id) { create(:course, name: "JavaScript Basics", id: 12345) }
  let!(:course_link) { create(:course_link, link: "https://ruby-lang.org") }
  let!(:course_link_with_id) { create(:course_link, link: "https://javascript.info", id: 54321) }

  describe "searching with unstripped values" do
    context "when searching by name with leading and trailing whitespace" do
      it "finds the course by stripping whitespace from the search query" do
        get :show, params: {
          resource_name: "course",
          global: false,
          q: "  Ruby Programming  "
        }

        expect(response).to have_http_status(:ok)
        expect(json["courses"]["results"].size).to eq(1)
        expect(json["courses"]["results"].first["_label"]).to include("Ruby Programming")
      end

      it "finds the course by partial name with whitespace" do
        get :show, params: {
          resource_name: "course",
          global: false,
          q: "  Ruby  "
        }

        expect(response).to have_http_status(:ok)
        expect(json["courses"]["results"].size).to eq(1)
        expect(json["courses"]["results"].first["_label"]).to include("Ruby Programming")
      end
    end

    context "when searching by ID with whitespace" do
      it "finds the course by ID with leading and trailing whitespace" do
        get :show, params: {
          resource_name: "course",
          global: false,
          q: "  #{course_with_id.id}  "
        }

        expect(response).to have_http_status(:ok)
        expect(json["courses"]["results"].size).to eq(1)
        expect(json["courses"]["results"].first["_label"]).to include("JavaScript Basics")
      end
    end

    context "when searching with tabs and newlines" do
      it "finds the course by stripping various whitespace characters" do
        get :show, params: {
          resource_name: "course",
          global: false,
          q: "\t\nRuby\t\n"
        }

        expect(response).to have_http_status(:ok)
        expect(json["courses"]["results"].size).to eq(1)
        expect(json["courses"]["results"].first["_label"]).to include("Ruby Programming")
      end
    end

    context "when searching with only whitespace" do
      it "returns all courses when query becomes empty after stripping" do
        get :show, params: {
          resource_name: "course",
          global: false,
          q: "   "
        }

        expect(response).to have_http_status(:ok)
        # When search query is empty, ILIKE '%%' matches all courses
        expect(json["courses"]["results"].size).to eq(4)
      end
    end
  end

  describe "searching course_link with unstripped values (should fail)" do
    context "when searching by link with leading and trailing whitespace" do
      it "fails to find the course_link because whitespace is not stripped in resource query" do
        get :show, params: {
          resource_name: "course_link",
          global: false,
          q: "  ruby-lang  "
        }

        expect(response).to have_http_status(:ok)
        # This should fail because CourseLink uses params[:q] directly without stripping
        # The query becomes: link ILIKE '%  ruby-lang  %' which won't match 'https://ruby-lang.org'
        expect(json["course links"]["results"].size).to eq(0)
      end

      it "fails to find the course_link by partial link with whitespace" do
        get :show, params: {
          resource_name: "course_link",
          global: false,
          q: "  https://ruby  "
        }

        expect(response).to have_http_status(:ok)
        # This should fail because the whitespace prevents the match
        expect(json["course links"]["results"].size).to eq(0)
      end
    end

    context "when searching by ID with whitespace" do
      it "unexpectedly finds the course_link by ID because PostgreSQL converts strings to integers" do
        get :show, params: {
          resource_name: "course_link",
          global: false,
          q: "  #{course_link_with_id.id}  "
        }

        expect(response).to have_http_status(:ok)
        # PostgreSQL converts "  54321  " to integer 54321, so this actually works
        # This demonstrates that ID searches are more forgiving than text searches
        expect(json["course links"]["results"].size).to eq(1)
        expect(json["course links"]["results"].first["_label"]).to include("javascript.info")
      end
    end

    context "when searching with tabs and newlines" do
      it "fails to find the course_link because various whitespace characters prevent match" do
        get :show, params: {
          resource_name: "course_link",
          global: false,
          q: "\t\nruby-lang\t\n"
        }

        expect(response).to have_http_status(:ok)
        # This should fail because the whitespace characters prevent the match
        expect(json["course links"]["results"].size).to eq(0)
      end
    end
  end
end
