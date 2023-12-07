class Avo::Actions::ShowCurrentTime < Avo::BaseAction
  self.name = "Show current time"
  self.standalone = true
  self.stimulus_controllers = "city-in-country"

  def fields
    field :country,
      as: :select,
      name: "Country",
      options: Course.countries.map { |country| [country, country] }.prepend(["-", nil]).to_h,
      html: {
        edit: {
          input: {
            data: {
              action: "city-in-country#onCountryChange"
            }
          }
        }
      }
    field :city,
      as: :select,
      name: "City",
      options: Course.cities.values.flatten.map { |city| [city, city] }.to_h,
      display_value: false
  end

  def handle(**args)
    city = args.dig(:fields, :city)
    timezone_id = Course.timezones.find { |_, cities| cities.include?(city) }&.first

    if timezone_id
      formatted_current_time = TZInfo::Timezone.get(timezone_id).now.strftime('%H:%M:%S')

      succeed "In #{city} it's now #{formatted_current_time}."
    else
      warn "No city chosen"
    end
  end
end
