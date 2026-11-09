# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Distribution chart", type: :request do
  let(:admin_user) { create :user, roles: {admin: true} }

  before { login_as admin_user }

  # The rows of the summary list, top to bottom, as [label, count].
  def summary_rows(field_id)
    Nokogiri::HTML(response.body).css("##{field_id}-summary li").map do |row|
      row.css("div").map { |cell| cell.text.strip }.reject(&:empty?)
    end
  end

  it "adds up the counts of blank values, which share a label" do
    create_list :project, 2, status: nil
    create_list :project, 3, status: ""
    create_list :project, 4, status: "closed"

    get "/admin/projects/status/distribution_chart"

    expect(response).to have_http_status(:ok)
    expect(summary_rows(:status)).to eq [["—", "5"], ["closed", "4"]]
  end

  it "adds up the counts of associated records with the same title" do
    first_namesake = create :user, first_name: "Alex", last_name: "Doe"
    second_namesake = create :user, first_name: "Alex", last_name: "Doe"
    create_list :project, 2, user: first_namesake
    create_list :project, 3, user: second_namesake

    get "/admin/projects/user/distribution_chart"

    expect(response).to have_http_status(:ok)
    expect(summary_rows(:user)).to include ["Alex Doe", "5"]
  end
end
