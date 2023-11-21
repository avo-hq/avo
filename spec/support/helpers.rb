def parsed_response
  JSON.parse(response.body)
end

def find_field_element(field_id)
  find("[data-field-id='#{field_id}']")
end

def field_wrapper(field_id, field_type = nil)
  if field_type.present?
    find("[data-field-id='#{field_id}'][data-field-type='#{field_type}']")
  else
    find("[data-field-id='#{field_id}']")
  end
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

def json_headers
  {"Content-Type" => "application/json"}
end

def stub_pro_license_request
  stub_request(:post, Avo::Licensing::HQ::ENDPOINT).with(body: hash_including({
    license: "pro",
    license_key: "license_123"
  }.stringify_keys)).to_return(status: 200, body: {id: "pro", valid: true}.to_json, headers: json_headers)
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

# Generators helpers
def check_files_and_clean_up(files = [], delete: true)
  files = Array.wrap files

  check_files_exist files
  delete_files(files) if delete
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

# Closes and reopens the browser window in system tests.
# That will reset any mocks/stubs/timezone setting you do at the code level.
def reset_browser
  Capybara.current_session.quit
end
