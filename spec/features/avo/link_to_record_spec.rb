require "rails_helper"

RSpec.feature "link_to_record on index", type: :feature do
  let!(:playground) do
    Playground.create!(
      name: "Linked",
      number_value: 42,
      date_value: Date.new(2026, 10, 5),
      time_value: "12:30:00",
      date_time_value: Time.utc(2026, 10, 5, 12, 30)
    )
  end

  after do
    Avo::Resources::Playground.restore_items_from_backup
  end

  def index_cell(field_id)
    find("[data-resource-id='#{playground.to_param}'] [data-field-id='#{field_id}']")
  end

  describe "with link_to_record: true" do
    before do
      Avo::Resources::Playground.with_temporary_items do
        field :id, as: :id
        field :number_value, as: :number, link_to_record: true
        field :date_value, as: :date, link_to_record: true
        field :time_value, as: :time, link_to_record: true
        field :date_time_value, as: :date_time, link_to_record: true
      end
    end

    %w[number_value date_value time_value date_time_value].each do |field_id|
      it "links the #{field_id} cell to the record" do
        visit avo.resources_playgrounds_path

        expect(index_cell(field_id)).to have_link href: avo.resources_playground_path(playground)
      end
    end
  end

  describe "without link_to_record" do
    before do
      Avo::Resources::Playground.with_temporary_items do
        field :id, as: :id
        field :number_value, as: :number
        field :date_value, as: :date
        field :time_value, as: :time
        field :date_time_value, as: :date_time
      end
    end

    %w[number_value date_value time_value date_time_value].each do |field_id|
      it "does not link the #{field_id} cell" do
        visit avo.resources_playgrounds_path

        expect(index_cell(field_id)).not_to have_link
      end
    end
  end
end
