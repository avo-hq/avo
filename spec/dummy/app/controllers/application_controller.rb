class ApplicationController < ActionController::Base
  def set_body_classes
    # This doesn't get called
    @body_classes = "#{super} !bg-red-500"
  end
end
