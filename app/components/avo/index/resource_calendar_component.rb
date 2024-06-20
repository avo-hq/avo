# frozen_string_literal: true

class Avo::Index::ResourceCalendarComponent < Avo::BaseComponent
  attr_reader :actions

  def initialize(resources: nil, resource: nil, reflection: nil, parent_record: nil, parent_resource: nil, actions: nil, date: nil)
    @resources = resources
    @resource = resource
    @reflection = reflection
    @parent_record = parent_record
    @parent_resource = parent_resource
    @actions = actions
    @date = date
  end

  def month_offset(date)
    # you might want to update this based on your first day of the week (Sun/Mon)
    date.beginning_of_month.wday - 1
  end

  def today?(day)
    day == Date.today
  end

  def today_class(day)
    "bg-rose-200" if today?(day)
  end
end
