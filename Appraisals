["3.0.3", "3.1.0", "3.2.1"].each do |ruby_version|
  ["6.0", "6.1", "7.0"].each do |rails_version|
    appraise "rails-#{rails_version}-ruby-#{ruby_version}" do
      gem "rails", "~> #{rails_version}.0"
    end
  end
end
