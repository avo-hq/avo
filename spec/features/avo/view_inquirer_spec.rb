# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Avo::ViewInquirer", type: :feature do
  describe "tests" do
    it "test" do
      view = Avo::ViewInquirer.new :index
      assert view.form? == false
      assert view.display?
      assert view.index?
      assert view == :index
      assert view == "index"

      view = Avo::ViewInquirer.new :show
      assert view.form? == false
      assert view.display?
      assert view.show?
      assert view == :show
      assert view == "show"

      view = Avo::ViewInquirer.new :new
      assert view.display? == false
      assert view.form?
      assert view.new?
      assert view == :new
      assert view == "new"
    end
  end
end
