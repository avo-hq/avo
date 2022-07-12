RSpec.configure do |config|
  config.around :example, :tz do |example|
    initial_tz = ENV["TZ"]
    ENV["TZ"] = example.metadata[:tz]
    example.run
    ENV["TZ"] = initial_tz
  end
end
