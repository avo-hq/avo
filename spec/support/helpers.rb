def parsed_response
  JSON.parse(response.body)
end

def find_field_element(field_id)
  find("[data-field-id='#{field_id}']")
end

def find_field_value_element(field_id)
  find("[data-field-id='#{field_id}'] [data-slot='value']")
end

def field_element_by_resource_id(field_id, resource_id = nil)
  if resource_id.present?
    find("[data-resource-id='#{resource_id}'] [data-field-id='#{field_id}']")
  else
    find("[data-field-id='#{field_id}']")
  end
end

def show_field_value(field_id)
  find_field_value_element(field_id).text
end

def edit_field_value(field_id)
  find_field_value_element(field_id).find('input').value
end

def index_field_value(field_id, resource_id)
  field_element_by_resource_id(field_id, resource_id).text
end

def empty_dash
  "—"
end

def json_headers
  {"Content-Type" => "application/json"}
end

def stub_pro_license_request
  stub_request(:post, Avo::Licensing::HQ::ENDPOINT).with(body: hash_including({
    license: "pro",
    license_key: "license_123"
  }.stringify_keys)).to_return(status: 200, body: {id: "pro", valid: true}.to_json, headers: json_headers)
end

def write_in_search(input)
  find("input.aa-Input").set(input)
end

def confirm_alert
  page.driver.browser.switch_to.alert.accept
end

def select_first_result_in_search
  find(".aa-Input").send_keys :arrow_down
  find(".aa-Input").send_keys :return
end

class DummyRequest
  attr_accessor :ip
  attr_accessor :host
  attr_accessor :port

  def initialize(ip, host, port)
    @ip = ip
    @host = host
    @port = port
  end
end

def open_filters_menu
  find('[data-button="resource-filters"]').click
end

def toggle_filters_menu
  open_filters_menu
end

def click_tab(tab_name = '', within: nil**args)
  if within.present?
    within within do
      within find('[data-controller="tabs"] turbo-frame:not(.hidden) [data-target="tab-switcher"]') do
        find_link(tab_name).click
      end
    end
  else
    within find('[data-controller="tabs"] turbo-frame:not(.hidden) [data-target="tab-switcher"]') do
      find_link(tab_name).click
    end
  end
end

def first_tab_group
  find_all('[data-controller="tabs"]')[0]
end

def second_tab_group
  find_all('[data-controller="tabs"]')[1]
end

def third_tab_group
  find_all('[data-controller="tabs"]')[2]
end

# Generators helpers
def check_files_and_clean_up(files = [])
  files = Array.wrap files

  check_files_exist files
  delete_files files
end

def check_files_exist(files = [])
  files.each do |paths|
    path = Rails.root.join(*paths)

    expect(File).to exist path.to_s
  end
end

def delete_files(files = [])
  files.each do |paths|
    path = Rails.root.join(*paths)
    File.delete(path.to_s) if File.exist?(path.to_s)
  end
end

def avo_home_path
  if Avo.configuration.home_path.respond_to? :call
    instance_exec(&Avo.configuration.home_path)
  else
    Avo.configuration.home_path
  end
end

def reload_page
  page.evaluate_script("window.location.reload()")
end

def main_sidebar
  find('[data-sidebar-target="sidebar"]')
end

def click_on_sidebar_item(label)
  within main_sidebar do
    click_on label
  end
end

# Save a record and wait for the page to load
def save
  click_on "Save"
  wait_for_loaded
end

# Closes and reopens the browser window in system tests.
# That will reset any mocks/stubs/timezone setting you do at the code level.
def reset_browser
  Capybara.current_session.quit
end

def set_picker_day(date)
  find(".flatpickr-day[aria-label=\"#{date}\"]").click
end

def set_picker_hour(value)
  find(".flatpickr-hour").set(value)
end

def set_picker_minute(value)
  find(".flatpickr-minute").set(value)
end

def set_picker_second(value)
  find(".flatpickr-second").set(value)
end

def open_picker
  text_input.click
end

def close_picker
  find('[data-target="title"]').click
  sleep 0.3
end
