["3.1.4", "3.3.0"].each do |ruby_version|
  ["6.1", "7.1", "7.2.0.beta2"].each do |rails_version|
    appraise "rails-#{rails_version}-ruby-#{ruby_version}" do
      gem "psych", "< 4"
      gem "rails", "~> #{rails_version}"
      gem "activestorage", "~> #{rails_version}"
      gem "activestorage"
    end
  end
end
