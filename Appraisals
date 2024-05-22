["3.1.4", "3.2.2", "3.3.0"].each do |ruby_version|
  ["6.1", "7.1"].each do |rails_version|
    appraise "rails-#{rails_version}-ruby-#{ruby_version}" do
      gem "psych", "< 4"
      if rails_version == "main"
        gem "rails", github: "rails/rails", branch: "main"
      else
        gem "rails", "~> #{rails_version}"
      end
      gem "ransack", "~> 4.1", ">= 4.1.1"

      # source "https://rubygems.pkg.github.com/avo-hq" do
      #   gem "avo-dynamic_filters"
      # end
    end
  end

  appraise "rails-8.0-ruby-#{ruby_version}" do
    gem "psych", "< 4"
    gem "rails", github: "rails/rails", branch: "main"
    gem "activestorage", github: "rails/rails", branch: "main"
    gem "acts-as-taggable-on", github: "avo-hq/acts-as-taggable-on"
    gem "ransack", "~> 4.1", ">= 4.1.1"
  end
end
