["6.0", "6.1"].each do |rails_version|
  appraise "rails-#{rails_version}-ruby-2.6" do
    gem "rails", "~> #{rails_version}.0"
  end

  appraise "rails-#{rails_version}-ruby-2.7" do
    gem "rails", "~> #{rails_version}.0"
  end

  # appraise "rails-#{rails_version}-ruby-3.0" do
  #   gem "rails", "~> #{rails_version}.0"
  #   gem "pagy", "~> 4.0"
  # end
end
