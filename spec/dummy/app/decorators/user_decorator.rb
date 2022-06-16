class UserDecorator < Draper::Decorator
  delegate_all

  def name
    "#{first_name} #{last_name}"
  end
end
