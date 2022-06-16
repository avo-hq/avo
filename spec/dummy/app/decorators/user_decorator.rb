class UserDecorator < Draper::Decorator
  delegate_all

  def name
    "#{first_name} #{last_name}"
  end

  # Returning the same thing just to test out the decoration functionality
  def first_name
    object.first_name
  end
end
