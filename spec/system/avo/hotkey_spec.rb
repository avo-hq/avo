require "rails_helper"

RSpec.describe "Keyboard shortcuts", type: :system do
  def dispatch_keydown(key, code: nil, shift_key: false, ctrl_key: false, meta_key: false)
    page.execute_script(<<~JS)
      const eventOptions = {
        key: #{key.to_json},
        code: #{code.to_json},
        shiftKey: #{shift_key},
        ctrlKey: #{ctrl_key},
        metaKey: #{meta_key},
        bubbles: true,
        cancelable: true
      }

      document.dispatchEvent(new KeyboardEvent("keydown", eventOptions))
      window.dispatchEvent(new KeyboardEvent("keydown", eventOptions))
    JS
  end

  def active_element_value
    page.evaluate_script("document.activeElement && document.activeElement.value")
  end

  def dispatch_active_element_keydown(key)
    page.execute_script(<<~JS)
      const activeElement = document.activeElement
      if (activeElement) {
        activeElement.dispatchEvent(new KeyboardEvent("keydown", {
          key: #{key.to_json},
          bubbles: true,
          cancelable: true
        }))
      }
    JS
  end

  def dispatch_document_keydown(key, code: nil, shift_key: false, ctrl_key: false, meta_key: false, alt_key: false)
    page.evaluate_script(<<~JS)
      const event = new KeyboardEvent("keydown", {
        key: #{key.to_json},
        code: #{code.to_json},
        shiftKey: #{shift_key},
        ctrlKey: #{ctrl_key},
        metaKey: #{meta_key},
        altKey: #{alt_key},
        bubbles: true,
        cancelable: true
      })

      const dispatchResult = document.dispatchEvent(event)

      {
        defaultPrevented: event.defaultPrevented,
        dispatchResult: dispatchResult
      }
    JS
  end

  it "opens the keyboard shortcuts panel and closes it with escape" do
    visit "/admin/resources/projects"

    expect(page).to have_css(".hotkey[hidden]", visible: false)

    dispatch_keydown("?", code: "Slash", shift_key: true)

    expect(page).to have_css(".hotkey", visible: true)
    expect(page).to have_text("Keyboard shortcuts")

    dispatch_keydown("Escape")

    expect(page).to have_css(".hotkey[hidden]", visible: false)
  end

  it "does not open the keyboard shortcuts panel while typing in a search field" do
    visit "/admin/resources/projects"

    search_input = find("[data-resource-search-target='input']")

    search_input.click
    search_input.send_keys("?")

    expect(search_input.value).to include("?")
    expect(page).to have_css(".hotkey[hidden]", visible: false)
  end

  it "applies kbd--called animation feedback when a hotkey fires" do
    visit "/admin/resources/projects"

    # Prevent the click from navigating so the kbd element stays in the DOM
    page.execute_script(<<~JS)
      document.querySelector('[data-hotkey="u"]').addEventListener('click', (e) => e.preventDefault())
    JS

    dispatch_keydown("u")

    expect(page).to have_css('[data-hotkey="u"] kbd.kbd--called')
  end

  it "navigates to resources using sidebar hotkeys" do
    visit "/admin/resources/projects"

    dispatch_keydown("u")

    expect(page).to have_current_path("/admin/resources/users")
  end

  it "does not trigger sidebar hotkeys while typing in a search field" do
    visit "/admin/resources/projects"

    search_input = find("[data-resource-search-target='input']")

    search_input.click
    search_input.send_keys("u")

    expect(page).to have_current_path("/admin/resources/projects")
  end

  it "keeps row navigation in bounds after turbo-replacing table rows" do
    target_project = create(:project, name: "Keyboard navigator target")
    create_list(:project, 3)

    visit "/admin/resources/projects"

    3.times { dispatch_keydown("ArrowDown") }
    expect(page).to have_css("tr.table-row.is-keyboard-focused")

    write_in_search(target_project.name)

    expect(page).to have_selector("[data-component-name='avo/index/table_row_component'][data-resource-id='#{target_project.to_param}']")
    expect(page).to have_css("tr[data-visit-path]", count: 1)

    dispatch_keydown("ArrowUp")

    focused_row = find("tr.table-row.is-keyboard-focused")
    expect(focused_row["data-resource-id"]).to eq(target_project.to_param)
  end

  it "does not swallow slash on pages without search input" do
    project = create(:project)

    visit "/admin/resources/projects/#{project.id}"

    result = dispatch_document_keydown("/", code: "Slash")

    expect(result["defaultPrevented"]).to be(false)
    expect(result["dispatchResult"]).to be(true)
  end

  it "opens the edit page using the edit hotkey" do
    project = create(:project)

    visit "/admin/resources/projects/#{project.id}"

    dispatch_keydown("e")

    expect(page).to have_current_path("/admin/resources/projects/#{project.id}/edit", ignore_query: true)
  end

  it "goes back using the back hotkey" do
    project = create(:project)

    visit "/admin/resources/projects/#{project.id}/edit"

    dispatch_keydown("b")

    expect(page).to have_current_path("/admin/resources/projects/#{project.id}")
  end

  it "opens the delete confirmation dialog using the delete hotkey" do
    project = create(:project)

    visit "/admin/resources/projects/#{project.id}"

    dispatch_keydown("d")

    expect(page).to have_css("dialog#turbo-confirm[open]", visible: true)
    expect(active_element_value).to eq("confirm")
    expect(page).to have_button("No, cancel")
  end

  it "navigates the delete confirmation dialog with the arrow keys" do
    project = create(:project)

    visit "/admin/resources/projects/#{project.id}"

    dispatch_keydown("d")

    expect(page).to have_css("dialog#turbo-confirm[open]", visible: true)
    expect(active_element_value).to eq("confirm")

    dispatch_active_element_keydown("ArrowDown")
    expect(active_element_value).to eq("cancel")

    dispatch_active_element_keydown("ArrowUp")
    expect(active_element_value).to eq("confirm")
  end

  # it "submits the form with command or control enter" do
  #   project = create(:project, name: "Original name")

  #   visit "/admin/resources/projects/#{project.id}/edit"

  #   fill_in "project_name", with: "Updated from hotkey"
  #   dispatch_keydown("Enter", meta_key: true)

  #   expect(page).to have_text("Project was successfully updated")
  #   expect(page).to have_current_path("/admin/resources/projects/#{project.id}")
  #   expect(project.reload.name).to eq("Updated from hotkey")
  # end
end
