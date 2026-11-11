# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Grouped filter options", type: :request do
  let(:admin_user) { create :user, roles: {admin: true} }
  let!(:event) { create :event }
  let!(:accountant) { create :volunteer, event:, name: "Ada Accountant", department: "Finance", skills: ["writing"] }
  let!(:developer) { create :volunteer, event:, name: "Dan Developer", department: "development", skills: ["programming", "database"] }

  before { login_as admin_user }

  def encode(filters)
    Avo::Filters::BaseFilter.encode_filters(filters)
  end

  def filter_select(filter_class)
    Nokogiri::HTML(response.body).at_css("select[data-filter-class='#{filter_class}']")
  end

  it "lists the options of a select filter in optgroups" do
    get "/admin/resources/volunteers"

    select = filter_select("Avo::Filters::VolunteerDepartmentFilter")

    expect(select.css("optgroup").map { |group| group["label"] }).to eq(["Administration", "Operations", "Technology"])
    expect(select.css("optgroup[label='Technology'] option").map { |option| [option.text, option["value"]] }).to eq([
      ["Development", "development"],
      ["Support", "support"],
      ["Infrastructure", "infrastructure"]
    ])
  end

  it "selects the applied option inside its group and filters the records" do
    get "/admin/resources/volunteers", params: {encoded_filters: encode("Avo::Filters::VolunteerDepartmentFilter" => "development")}

    select = filter_select("Avo::Filters::VolunteerDepartmentFilter")

    expect(select.css("optgroup[label='Technology'] option[selected]").map(&:text)).to eq(["Development"])
    expect(response.body).to include("Dan Developer")
    expect(response.body).not_to include("Ada Accountant")
  end

  it "lists the options of a multiple select filter in optgroups and sizes the box for the group labels" do
    get "/admin/resources/volunteers"

    select = filter_select("Avo::Filters::VolunteerSkillsFilter")

    expect(select.css("optgroup").map { |group| group["label"] }).to eq(["Technical Skills", "Communication Skills", "Leadership Skills"])
    expect(select["size"]).to eq("4")
  end

  it "selects the applied options across groups and filters the records" do
    get "/admin/resources/volunteers", params: {encoded_filters: encode("Avo::Filters::VolunteerSkillsFilter" => ["database", "public_speaking"])}

    select = filter_select("Avo::Filters::VolunteerSkillsFilter")

    expect(select.css("option[selected]").map(&:text)).to eq(["Database Management", "Public Speaking"])
    expect(response.body).to include("Dan Developer")
    expect(response.body).not_to include("Ada Accountant")
  end
end
