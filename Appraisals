["3.1.4", "3.3.0"].each do |ruby_version|
  ["6.1", "7.1", "7.2.0.beta2"].each do |rails_version|
    appraise "rails-#{rails_version}-ruby-#{ruby_version}" do
      gem "psych", "< 4"
      gem "rails", "~> #{rails_version}"
      gem "activestorage", "~> #{rails_version}"
      gem "activestorage"
    end
  end

  # TODO: we'll probably have to remove these when Rails 8 is released
  appraise "rails-8.0-ruby-#{ruby_version}" do
    gem "psych", "< 4"
    gem "rails", github: "rails/rails", branch: "main"
    gem "activestorage", github: "rails/rails", branch: "main"

    # Temporary Rails 8 support
    gem "acts-as-taggable-on", github: "avo-hq/acts-as-taggable-on"
  end
end
