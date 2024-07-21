# frozen_string_literal: true

class Avo::Index::ResourceCalendarComponent < Avo::BaseComponent
  attr_reader :resources, :resource, :date, :starts_at, :title

  def initialize(resources: nil, resource: nil, reflection: nil, parent_record: nil, parent_resource: nil, actions: nil, date: nil)
    @resources = resources
    @resource = resource
    @reflection = reflection
    @parent_record = parent_record
    @parent_resource = parent_resource
    @actions = actions
    @date = date
  end

  def starts_at
    @resource&.calendar_view&.dig(:starts_at) || :created_at
  end

  def week_start
    @resource&.calendar_view&.dig(:week_start) || :sunday
  end

  def weekdays_with_offset
    weekdays = Date::ABBR_DAYNAMES
    weekdays = weekdays.rotate if week_start == :monday
    weekdays
  end

  def month_offset
    first_day = date.beginning_of_month.wday
    first_day -= 1 if week_start == :monday
  end

  def today?(day)
    day == Date.today
  end

  def today_class(day)
    "bg-primary-100" if today?(day)
  end

  def resources_for_day(day)
    items = resources.filter { |r| r.record.send(starts_at).beginning_of_day == day }
    items.sort_by { |r| r.record.send(starts_at) }
  end

  def prev_date
    date.last_month
  end

  def next_date
    date.next_month
  end
end
