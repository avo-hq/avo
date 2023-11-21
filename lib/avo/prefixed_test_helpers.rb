#   This module is used to namespace all of the methods from Avo::TestHelpers.
#
#   It loops through all of the public instance methods from Avo::TestHelpers and defines new methods in the current
# module with the same name but prefixed with "avo_".
#
#   For example, if Avo::TestHelpers has a public instance method called example_method, this code will define a new
# method called avo_example_method in Avo::PrefixedTestHelpers module which when called will call example_method
# with the same arguments.

module Avo
  module PrefixedTestHelpers
    include Avo::TestHelpers

    Avo::TestHelpers.public_instance_methods.each do |method|
      define_method("avo_#{method}") do |**args|
        send(method, **args)
      end
    end
  end
end
