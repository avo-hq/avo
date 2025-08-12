["3.3.0", "3.4.5"].each do |ruby_version|
  ["7.1", "8.0"].each do |rails_version|
    appraise "rails-#{rails_version}-ruby-#{ruby_version}" do
      gem "psych", "< 4"
      gem "rails", "~> #{rails_version}"
      gem "activestorage", "~> #{rails_version}"
      gem "acts-as-taggable-on"

      if rails_version == "8.0" && ruby_version == "3.3.0"
        gem "view_component", "4.0.0"
      else
        gem "view_component", "3.23.2"
      end
    end
  end
end
