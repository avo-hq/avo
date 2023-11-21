["3.0.3", "3.2.2"].each do |ruby_version|
  ["6.0", "6.1", "7.0", "7.1"].each do |rails_version|
    appraise "rails-#{rails_version}-ruby-#{ruby_version}" do
      gem "psych", "< 4"
      gem "rails", "~> #{rails_version}"
      gem "ransack", "~> 4.1", ">= 4.1.1"

      # source "https://rubygems.pkg.github.com/avo-hq" do
      #   gem "avo-dynamic_filters"
      # end
    end
  end
end
