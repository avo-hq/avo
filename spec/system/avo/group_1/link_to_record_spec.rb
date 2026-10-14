require "rails_helper"

RSpec.describe "link_to_record on number and date fields", type: :system do
  let!(:playground) { Playground.create!(name: "Linked", number_value: 42, date_value: Date.new(1988, 2, 10), time_value: "16:22:00", date_time_value: Time.utc(1988, 2, 10, 16, 22)) }
  let(:field_ids) { %w[number_value date_value time_value date_time_value] }

  def define_fields(options = {})
    Avo::Resources::Playground.with_temporary_items do
      field :number_value, as: :number, **options
      field :date_value, as: :date, **options
      field :time_value, as: :time, **options
      field :date_time_value, as: :date_time, relative: false, format: "cccc, d LLLL yyyy, HH:mm ZZZZ", **options
    end
  end

  after { Avo::Resources::Playground.restore_items_from_backup }

  it "links every cell to the record and keeps the formatted date" do
    define_fields(link_to_record: true)
    visit avo.resources_playgrounds_path

    field_ids.each do |field_id|
      expect(field_element_by_resource_id(field_id, playground.to_param)).to have_link(href: avo.resources_playground_path(playground))
    end

    click_link "Wednesday, 10 February 1988, 16:22 UTC"
    expect(page).to have_current_path avo.resources_playground_path(playground)
  end

  it "renders plain cells without the option" do
    define_fields
    visit avo.resources_playgrounds_path

    field_ids.each do |field_id|
      expect(field_element_by_resource_id(field_id, playground.to_param)).to have_no_link
    end
  end
end
