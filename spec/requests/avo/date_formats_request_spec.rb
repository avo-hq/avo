require "rails_helper"

# The date-field Stimulus controller formats the value in the browser with the
# Luxon format the field hands it. With `config.date_format`, `config.date_time_format`,
# and `config.time_format` set, fields without their own `format:` hand over those.
RSpec.describe "Date formats", type: :request do
  let(:admin_user) { create :user, roles: {admin: true} }
  let!(:playground) do
    Playground.create!(name: "Dates", date_value: Date.new(1988, 2, 10), time_value: "16:22:00", date_time_value: Time.utc(1988, 2, 10, 16, 22))
  end

  around do |example|
    originals = %i[date_format date_time_format time_format].index_with { |option| Avo.configuration.public_send(option) }
    example.run
    originals.each { |option, value| Avo.configuration.public_send(:"#{option}=", value) }
  end

  before do
    login_as admin_user

    Avo.configuration.date_format = "dd.LL.yyyy"
    Avo.configuration.date_time_format = "dd.LL.yyyy HH:mm"
    Avo.configuration.time_format = "HH:mm"
  end

  def format_values
    Nokogiri::HTML(response.body).css("[data-date-field-format-value]").to_h do |element|
      [element["data-date-field-field-type-value"], element["data-date-field-format-value"]]
    end
  end

  it "displays the configured formats on show" do
    get "/admin/resources/playgrounds/#{playground.id}"

    expect(response).to have_http_status(:ok)
    expect(format_values).to eq("date" => "dd.LL.yyyy", "dateTime" => "dd.LL.yyyy HH:mm", "time" => "HH:mm")
  end

  it "displays the configured formats on index" do
    get "/admin/resources/playgrounds"

    expect(response).to have_http_status(:ok)
    expect(format_values).to eq("date" => "dd.LL.yyyy", "dateTime" => "dd.LL.yyyy HH:mm", "time" => "HH:mm")
  end
end
