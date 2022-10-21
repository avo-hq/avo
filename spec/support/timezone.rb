RSpec.configure do |config|
  config.around :example, :tz do |example|
    Time.use_zone(example.metadata[:tz]) do
      initial_timezone = ENV["TZ"]
      ENV["TZ"] = example.metadata[:tz]

      example.run

      ENV["TZ"] = initial_timezone
    end
  end
end
