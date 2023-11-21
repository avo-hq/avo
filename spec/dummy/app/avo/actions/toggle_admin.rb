class Avo::Actions::ToggleAdmin < Avo::BaseAction
  self.name = "Toggle admin"
  self.no_confirmation = true
  self.visible = -> {
    # puts ["view->", view].inspect
    # view.edit?
    # view.new?
    true
  }

  def handle(records:, **)
    records.each do |record|
      is_admin = record.roles["admin"].present?
      record.update roles: record.roles.merge!({admin: !is_admin})
    end

    succeed "New admin(s) on the board!"
  end
end
