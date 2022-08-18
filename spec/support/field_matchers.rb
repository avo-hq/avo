RSpec::Matchers.define :have_required_field do |expected|
  match do |page|
    expect(page).to have_field(expected)
    expect(find_field(expected)[:required]).to eq("required")
  end
end