# frozen_string_literal: true

require "rails_helper"

RSpec.feature Avo::SearchController, type: :controller do
  describe "searching with unstripped values" do
    context "when searching with leading and trailing whitespace" do
      it "'q' is stripped of leading and trailing whitespace" do
        expect(TestBuddy).to receive(:hi).with("params[:q]: '  Ruby Programming  ', q: 'Ruby Programming'").at_least :once

        get :show, params: {
          resource_name: "course",
          global: false,
          q: "  Ruby Programming  "
        }
      end
    end

    context "when searching with tabs and newlines" do
      it "'q' is stripped of tabs and newlines" do
        expect(TestBuddy).to receive(:hi).with("params[:q]: '\t\nRuby\t\n', q: 'Ruby'").at_least :once

        get :show, params: {
          resource_name: "course",
          global: false,
          q: "\t\nRuby\t\n"
        }
      end
    end

    context "when searching with only whitespace" do
      it "'q' is stripped of whitespace" do
        expect(TestBuddy).to receive(:hi).with("params[:q]: '   ', q: ''").at_least :once

        get :show, params: {
          resource_name: "course",
          global: false,
          q: "   "
        }
      end
    end
  end
end
