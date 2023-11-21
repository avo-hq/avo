require "rails_helper"

RSpec.feature "Fields view types", type: :system do
  let(:project) { create :project, :with_files }

  after :each do
    Avo::Resources::Project.restore_items_from_backup
  end

  it "default" do
    Avo::Resources::Project.with_temporary_items do
      field :files, as: :files
    end

    visit "/admin/resources/projects/#{project.id}"

    files_wrapper = find('[data-resource-show-target="filesFilesWrapper"]')
    expect(files_wrapper).to have_selector("div.button-group", count: 1)

    button_group = files_wrapper.find("div.button-group")
    expect(button_group).to have_selector('a[data-control="view-type-toggle-list"].text-gray-500', count: 1)
    expect(button_group).to have_selector('a[data-control="view-type-toggle-grid"].text-primary-500', count: 1)

    project.files.each do |file|
      expect(page).not_to have_content(ActiveSupport::NumberHelper.number_to_human_size(file.byte_size))
    end
  end

  it "hide view type switcher" do
    Avo::Resources::Project.with_temporary_items do
      field :files, as: :files, hide_view_type_switcher: true
    end

    visit "/admin/resources/projects/#{project.id}"

    files_wrapper = find('[data-resource-show-target="filesFilesWrapper"]')
    expect(files_wrapper).to have_selector("div.button-group", count: 0)
  end

  it "list view and change to grid, delete works on both" do
    Avo::Resources::Project.with_temporary_items do
      field :files, as: :files, view_type: :list
    end

    visit "/admin/resources/projects/#{project.id}"

    files_wrapper = find('[data-resource-show-target="filesFilesWrapper"]')
    expect(files_wrapper).to have_selector("div.button-group", count: 1)

    button_group = files_wrapper.find("div.button-group")
    expect(button_group).to have_selector('a[data-control="view-type-toggle-list"].text-primary-500', count: 1)
    expect(button_group).to have_selector('a[data-control="view-type-toggle-grid"].text-gray-500', count: 1)

    project.files.each do |file|
      expect(page).to have_content(ActiveSupport::NumberHelper.number_to_human_size(file.byte_size))
    end

    destroy_path = "/admin/resources/projects/#{project.id}/active_storage_attachments/files/#{project.files.first.id}"
    accept_alert "Are you sure?" do
      find("a[data-turbo-method='delete'][href='#{destroy_path}']").click
    end
    wait_for_loaded
    expect(page).to have_text("Attachment destroyed")

    find('a[data-control="view-type-toggle-grid"]').click

    expect(button_group).to have_selector('a[data-control="view-type-toggle-list"].text-gray-500', count: 1)
    expect(button_group).to have_selector('a[data-control="view-type-toggle-grid"].text-primary-500', count: 1)

    project.files.each do |file|
      expect(page).not_to have_content(ActiveSupport::NumberHelper.number_to_human_size(file.byte_size))
    end

    destroy_path = "/admin/resources/projects/#{project.id}/active_storage_attachments/files/#{project.files.last.id}"
    accept_alert "Are you sure?" do
      find("a[data-turbo-method='delete'][href='#{destroy_path}']").click
    end
    wait_for_loaded
    expect(page).to have_text("Attachment destroyed")
  end
end
