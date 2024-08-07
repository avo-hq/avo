require "rails_helper"

RSpec.feature "CustomFieldsInResourceTools", type: :feature do
  let(:fish) { create :fish, name: :Salmon }

  describe "fish information" do
    before(:example) do
      visit avo.edit_resources_fish_path fish

      expect(page).to have_text "There should be an image of this fish below 🐠"

      fill_in "fish[fish_type]", with: "Fishy type"

      properties_fields = find_all('input[name="fish[properties][]"]')
      properties_fields.first.set("Fishy property 1")
      properties_fields.last.set("Fishy property 2")

      find('input[name="fish[information][name]"]').set("Fishy name")
      find('input[name="fish[information][history]"]').set("Fishy history")
      find('input[name="fish[information][age]"]').set("Fishy age")

      expect(properties_fields.count).to be 2
    end

    it "raise unnpermited params" do
      expect { save }.to raise_error("found unpermitted parameter: :age")
    end

    it "sends the params to the model ignoring unpermitted age" do
      expect_any_instance_of(Fish).to receive("fish_type=").with("Fishy type")
      expect_any_instance_of(Fish).to receive("properties=").with(["Fishy property 1", "Fishy property 2"])
      expect_any_instance_of(Fish).to receive("information=").with({name: "Fishy name", history: "Fishy history"})

      with_temporary_class_option(ActionController::Parameters, :action_on_unpermitted_parameters, :log) do
        save
      end
    end

    it "sends all the params to the model" do
      expect_any_instance_of(Fish).to receive("fish_type=").with("Fishy type")
      expect_any_instance_of(Fish).to receive("properties=").with(["Fishy property 1", "Fishy property 2"])
      expect_any_instance_of(Fish).to receive("information=").with({name: "Fishy name", history: "Fishy history", age: "Fishy age"})

      with_temporary_class_option(
        Avo::Resources::Fish,
        :extra_params,
        [
          :fish_type,
          :something_else,
          properties: [],
          information: [:name, :history, :age],
          reviews_attributes: [:body, :user_id]
        ]
      ) do
        save
      end
    end
  end
end
