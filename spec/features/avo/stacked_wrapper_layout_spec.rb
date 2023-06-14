require "rails_helper"

RSpec.feature "StackedWrapperLayouts", type: :feature do
  context "show" do
    subject { visit avo.resources_user_path admin }

    describe "with default settings" do
      context "with field default" do
        it "displays the inline layout" do
          subject

          expect(field_wrapper(:email, :text)[:class]).to include "field-wrapper-layout-inline"
        end
      end

      context "with field override to stacked" do
        it "displays the stacked layout" do
          subject

          expect(field_wrapper(:first_name)[:class]).to include "field-wrapper-layout-stacked"
        end
      end
    end

    describe "with stacked settings" do
      around do |example|
        Avo.configuration.field_wrapper_layout = :stacked
        example.run
        Avo.configuration.field_wrapper_layout = :inline
      end

      context "with field default" do
        it "displays the stacked layout" do
          subject

          expect(field_wrapper(:email, :text)[:class]).to include "field-wrapper-layout-stacked"
        end
      end

      context "with field override to stacked" do
        it "displays the stacked layout" do
          subject

          expect(field_wrapper(:first_name)[:class]).to include "field-wrapper-layout-stacked"
        end
      end
    end
  end

  context "edit" do
    subject { visit avo.edit_resources_user_path admin }

    describe "with default settings" do
      context "with field default" do
        it "displays the inline layout" do
          subject

          expect(field_wrapper(:email, :text)[:class]).to include "field-wrapper-layout-inline"
        end
      end

      context "with field override to stacked" do
        it "displays the stacked layout" do
          subject

          expect(field_wrapper(:first_name)[:class]).to include "field-wrapper-layout-stacked"
        end
      end
    end

    describe "with stacked settings" do
      before do
        Avo.configure do |config|
          config.field_wrapper_layout = :stacked
        end
      end

      context "with field default" do
        it "displays the stacked layout" do
          subject

          expect(field_wrapper(:last_name)[:class]).to include "field-wrapper-layout-stacked"
        end
      end

      context "with field override to stacked" do
        it "displays the stacked layout" do
          subject

          expect(field_wrapper(:first_name)[:class]).to include "field-wrapper-layout-stacked"
        end
      end
    end
  end
end
