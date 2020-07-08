def parsed_response
  JSON.parse(response.body)
end

def find_field_element(field_id)
  find("[field-id='#{field_id}']")
end

def find_field_value_element(field_id)
  find("[field-id='#{field_id}'] [data-slot='value']")
end

def find_field_element_by_component(field_component)
  find("[field-component='#{field_component}']")
end

def empty_dash
  '—'
end
