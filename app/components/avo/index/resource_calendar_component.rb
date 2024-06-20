# frozen_string_literal: true

class Avo::Index::ResourceCalendarComponent < Avo::BaseComponent
  attr_reader :date, :date_attribute

  def initialize(resources: nil, resource: nil, reflection: nil, parent_record: nil, parent_resource: nil, actions: nil, date: nil)
    @resources = resources
    @resource = resource
    @reflection = reflection
    @parent_record = parent_record
    @parent_resource = parent_resource
    @actions = actions
    @date = date
  end

  def date_attribute
    @resource&.calendar_view&.dig(:date_attribute) || :created_at
  end

  def month_offset
    # you might want to update this based on your first day of the week (Sun/Mon)
    date.beginning_of_month.wday - 1
  end

  def today?(day)
    day == Date.today
  end

  def today_class(day)
    "bg-rose-200" if today?(day)
  end

  def prev_date
    date.last_month
  end

  def next_date
    date.next_month
  end
end
