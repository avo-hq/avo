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

    it "treats :bulk_edit as a form view that is NOT single and IS bulk" do
      view = Avo::ViewInquirer.new(:bulk_edit)

      assert view.form?
      assert view.bulk?
      assert view.single? == false
      assert view.display? == false
      assert view.new? == false
      assert view.edit? == false
      assert view == :bulk_edit
      assert view == "bulk_edit"
    end

    it "does not flag :new, :edit, :create, :update, :show, or :index as bulk" do
      %i[new edit create update show index].each do |view_name|
        view = Avo::ViewInquirer.new(view_name)
        assert view.bulk? == false, "expected #{view_name} not to be bulk?"
      end
    end
  end
end
