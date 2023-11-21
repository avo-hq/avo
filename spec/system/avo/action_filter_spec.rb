require "rails_helper"

RSpec.feature "Actions", type: :system do
  it "shows the different types of alerts" do
    visit "/admin/resources/users"

    open_panel_action(action_name: "Dummy action")
    run_action

    base_classes = ".max-w-lg.w-full.shadow-lg.rounded.px-4.py-3.rounded.relative.border.text-white.pointer-events-auto"

    error_classes = "#{base_classes}.bg-red-400.border-red-600"
    success_classes = "#{base_classes}.bg-green-500.border-green-600"
    warning_classes = "#{base_classes}.bg-orange-400.border-orange-600"
    info_classes = "#{base_classes}.bg-blue-400.border-blue-600"

    expect(page).to have_selector error_classes
    expect(page).to have_selector success_classes
    expect(page).to have_selector warning_classes
    expect(page).to have_selector info_classes

    expect(page).to have_text "Success response ✌️"
    expect(page).to have_text "Warning response ✌️"
    expect(page).to have_text "Info response ✌️"
    expect(page).to have_text "Error response ✌️"
  end
end
