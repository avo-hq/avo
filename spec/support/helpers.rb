def parsed_response
  JSON.parse(response.body)
end

def find_field_element(field_id)
  find("[field-id='#{field_id}']")
end

def find_field_value_element(field_id)
  find("[field-id='#{field_id}'] [data-slot='value']")
end

def find_field_element_by_component(field_component, resource_id = nil)
  if resource_id.present?
    find("[resource-id='#{resource_id}'] [field-component='#{field_component}']")
  else
    find("[field-component='#{field_component}']")
  end
end

def empty_dash
  '—'
end

def json_headers
  { 'Content-Type' => 'application/json' }
end

def stub_pro_license_request
  stub_request(:post, Avo::HQ::ENDPOINT).with(body: hash_including({
    license: 'pro',
    license_key: 'license_123',
  }.stringify_keys)).to_return(status: 200, body: { id: 'pro', valid: true }.to_json, headers: json_headers)
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
