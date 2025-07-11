["3.3.0", "3.4.0"].each do |ruby_version|
  ["7.1", "8.0"].each do |rails_version|
    # Rails 8 requires ruby >= 3.2.0
    next if ruby_version == "3.1.4" && rails_version == "8.0"

    appraise "rails-#{rails_version}-ruby-#{ruby_version}" do
      gem "psych", "< 4"
      gem "rails", "~> #{rails_version}"
      gem "activestorage", "~> #{rails_version}"
      gem "acts-as-taggable-on"

      if rails_version == "6.1"
        # Fix `<module:LoggerThreadSafeLevel>': uninitialized constant ActiveSupport::LoggerThreadSafeLevel::Logger (NameError)
        # https://stackoverflow.com/questions/79360526/uninitialized-constant-activesupportloggerthreadsafelevellogger-nameerror
        gem "concurrent-ruby", "1.3.4"
      end
    end
  end
end
