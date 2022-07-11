require "rails_helper"
require "rails/generators"

RSpec.feature "action generator", type: :feature do
  it "generates the files" do
    file = Rails.root.join("app", "avo", "actions", "remove_user.rb").to_s

    Rails::Generators.invoke("avo:action", ["remove_user", "-q"], {destination_root: Rails.root})

    check_files_and_clean_up file
  end

  it "generates the standalone action" do
    file = Rails.root.join("app", "avo", "actions", "remove_user.rb").to_s

    Rails::Generators.invoke("avo:action", ["remove_user", "--standalone", "-q"], {destination_root: Rails.root})

    expect(File.read(file)).to include "self.standalone = true\n\n"
    check_files_and_clean_up file
  end
end
