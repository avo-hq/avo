class Avo::Actions::Test::Query < Avo::BaseAction
  self.name = "Test query access"
  self.message = -> {
    "message #{query.count} selected"
  }
  self.cancel_button_label = -> {
    "cancel_button_label #{query.count} selected"
  }
  self.confirm_button_label = -> {
    "confirm_button_label #{query.count} selected"
  }
  self.standalone = true

  def fields
    field :selected,default: "#{query.count} selected def fields"
  end

  def handle(**args)
    succeed "succeed #{query.count} selected"
  end
end
