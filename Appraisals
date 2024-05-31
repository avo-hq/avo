["3.1.4", "3.2.2", "3.3.0"].each do |ruby_version|
  ["6.1", "7.1"].each do |rails_version|
    appraise "rails-#{rails_version}-ruby-#{ruby_version}" do
      gem "psych", "< 4"
      gem "rails", "~> #{rails_version}"
      gem "ransack", "~> 4.1", ">= 4.1.1"

      # source "https://rubygems.pkg.github.com/avo-hq" do
      #   gem "avo-dynamic_filters"
      # end
    end
  end

  # TODO: we'll probably have to remove these when Rails 8 is released
  appraise "rails-8.0-ruby-#{ruby_version}" do
    gem "psych", "< 4"
    gem "rails", github: "rails/rails", branch: "main"
    gem "activestorage", github: "rails/rails", branch: "main"
    gem "acts-as-taggable-on", github: "avo-hq/acts-as-taggable-on"
    gem "ransack", "~> 4.1", ">= 4.1.1"
  end
end
