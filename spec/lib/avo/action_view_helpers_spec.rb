require "rails_helper"

# Resources and fields include ActionView's UrlHelper so code written on them — a resource method
# that links an owner, a field that renders a URL — can call link_to on self. Rails 8.2 extracted
# link_to, button_to and current_page? into NavigationHelper (rails/rails#58735), which the
# UrlHelper include no longer brings along, so both classes include that too. Trivially true below
# Rails 8.2; on Rails 8.2 it is the difference between a link and a NoMethodError.
RSpec.describe "ActionView link helpers on resources and fields" do
  [Avo::Resources::Base, Avo::Fields::BaseField].each do |klass|
    it "#{klass} responds to link_to and button_to" do
      expect(klass.method_defined?(:link_to)).to be true
      expect(klass.method_defined?(:button_to)).to be true
    end
  end
end
