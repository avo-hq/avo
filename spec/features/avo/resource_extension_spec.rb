require "rails_helper"

RSpec.feature "Resource extension", type: :feature do

  before_all do
    Avo::Resources::CourseLink.define_method :test_base_resource_extension do
      some_extended_method
    end
  end

  it "no extension" do
    expect(TestBuddy).not_to receive(:hi).with("Extension successfully")
    expect { Avo::Resources::CourseLink.new.test_base_resource_extension }.to raise_error(NameError)
  end

  it "with extension" do
    file_path = Rails.root.join("app/avo/base_resource.rb")
    FileUtils.mkdir_p(File.dirname(file_path))
    File.write file_path,
      <<~RUBY
        module Avo
          class BaseResource < Avo::Resources::Base
            def some_extended_method
              TestBuddy.hi("Extension successfully")
            end
          end
        end
      RUBY

    load file_path

    expect(TestBuddy).to receive(:hi).with("Extension successfully").at_least :once
    expect { Avo::Resources::CourseLink.new.test_base_resource_extension }.not_to raise_error

    File.delete(file_path) if File.exist?(file_path)
  end
end
