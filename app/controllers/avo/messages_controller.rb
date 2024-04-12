# This controller has been generated to enable Rails' resource routes.
# More information on https://docs.avohq.io/3.0/controllers.html
class Avo::MessagesController < Avo::ResourcesController
  def save_record_action
    puts ["@record->", @record, params].inspect
    if @record.new_record?
      entry = Entry.create! entryable: @record, creator: Current.user
      entry.entryable
    else
      super
    end
  end
end
