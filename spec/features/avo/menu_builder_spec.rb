require "rails_helper"

RSpec.feature "MenuBuilders", type: :feature do
  let(:block) {
    -> {
      section I18n.t("avo.dashboards"), icon: "dashboards" do
        dashboard :dashy, visible: -> { true }
        dashboard "Sales", visible: -> { true }

        group "All dashboards", visible: false do
          all_dashboards
        end
      end

      section "Resources", icon: "heroicons/outline/academic-cap" do
        group "Academia" do
          resource :course
          resource :course_link
        end

        group "Blog" do
          resource :posts
          resource :comments
        end

        group "Company" do
          resource :projects
          resource :team
          resource :reviews
        end

        group "People" do
          resource "UserResource", params: { filters: "eyJJc0FkbWluIjpbIm5vbl9hZG1pbnMiXX0%3D%0A" }
          resource :people
          resource :spouses
        end

        group "Other" do
          resource :fish
        end
      end

      section "Tools", icon: "heroicons/outline/finger-print" do
        all_tools
      end

      group do
        link "Avo", path: "https://avohq.io"
        link "Google", path: "https://google.com", target: :_blank
      end

      link "JSP", path: "https://jumpstartrails.com/", target: :_blank
    }
  }

  subject { Avo::Menu::Builder.parse_menu(&block) }

  before do
    allow_message_expectations_on_nil
    allow(Avo::App.license).to receive(:lacks_with_trial) { :resource_ordering }.and_return(false)
    allow(Avo::App.license).to receive(:lacks_with_trial) { :custom_tools }.and_return(false)
  end

  it "builds the menu" do
    expect(subject.items.count).to eq 5
    expect(subject.items.map(&:class)).to eq [Avo::Menu::Section, Avo::Menu::Section, Avo::Menu::Section, Avo::Menu::Group, Avo::Menu::Link]

    # First section
    expect(subject.items.first.items.count).to eq 3
    expect(subject.items.first.items.map(&:class)).to eq [Avo::Menu::Dashboard, Avo::Menu::Dashboard, Avo::Menu::Group]
    expect(subject.items.first.name).to eq "Dashboards"
    expect(subject.items.first.icon).to eq "dashboards"
    expect(subject.items.first.items.first.name).to eq ""
    expect(subject.items.first.items.first.icon).to be nil
    expect(subject.items.first.items.last.visible).to be false

    # Second section
    expect(subject.items.second.items.count).to eq 5
    expect(subject.items.second.name).to eq "Resources"
    expect(subject.items.second.icon).to eq "heroicons/outline/academic-cap"

    # Last item
    expect(subject.items.last.name).to eq "JSP"
    expect(subject.items.last.path).to eq "https://jumpstartrails.com/"
    expect(subject.items.last.target).to eq :_blank

    # Checking path generated when :params used
    users = subject.items.second.items[3].items.first
    expect(users.resource).to eq "UserResource"
    expect(users.params).to eq filters: "eyJJc0FkbWluIjpbIm5vbl9hZG1pbnMiXX0%3D%0A"
  end
end
