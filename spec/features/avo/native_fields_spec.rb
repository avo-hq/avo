require 'rails_helper'

RSpec.feature "NativeFields", type: :feature do
  let(:city) { create :city, is_capital: true }

  it "has the fields prefilled" do
    visit avo.edit_resources_city_path(city, show_native_fields: 1)

    expect(find_field('Name').value).to eq city.name
    expect(find_field('Population').value).to eq city.population.to_s
    expect(find_field('Is capital').value).to eq "1"
    expect(find_field('Features').value).to eq "\"#{city.features}\""
    expect(find_field('metadata', visible: false, disabled: true).value).to eq city.metadata

    expect(page).to have_css 'img[src="https://images.unsplash.com/photo-1660061993776-098c0ee403ac?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=MnwxfDB8MXxyYW5kb218MHx8fHx8fHx8MTY2MDMxMzc4NA&ixlib=rb-1.2.1&q=80&w=1080"]'
    expect(find_field('Image url').value).to eq city.image_url

    expect(page).to have_css 'trix-editor'
    expect(find_field('city[description]', visible: false).value).to include city.description.to_plain_text

    expect(page).to have_css 'div[data-controller="code-field"]'
    expect(find_field('city[tiny_description]', visible: false).value).to eq city.tiny_description

    expect(page).to have_select 'city[status]', options: ["Open", "Closed", "Quarantine"], selected: city.status
  end

  it "updates the record through the custom fields" do
    visit avo.edit_resources_city_path(city)

    fill_in 'city[name]', with: "Bucharest"
    fill_in 'city[population]', with: 101
    find('[name="city[is_capital]"]').set(false)
    fill_in 'city[features]', with: "{\"hey\": \"features\"}"
    find_field('metadata', visible: false, disabled: true).set("{\"hey\": \"metadata\"}")

    click_on "Save"

    city.reload

    expect(city.name).to eq "Bucharest"
    expect(city.population).to eq 101
    expect(city.is_capital).to eq false
    expect(city.features).to eq({"hey" => "features"})
  end
end
