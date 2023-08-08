["3.0.3", "3.2.2"].each do |ruby_version|
  appraise "rails-6.0-ruby-#{ruby_version}" do
    gem "rails", "~> 6.0.0"
    gem "ransack", "~> 3.1.0"
  end
end

["3.0.3", "3.2.2"].each do |ruby_version|
  ["6.1", "7.0"].each do |rails_version|
    appraise "rails-#{rails_version}-ruby-#{ruby_version}" do
      gem "rails", "~> #{rails_version}.0"
      gem "ransack", "~> 4.0.0"
    end
  end
end
