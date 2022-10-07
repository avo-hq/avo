require 'rails/generators'
require 'rails/generators/rails/model/model_generator'

module Rails
  module Generators
    class ModelGenerator
      hook_for :avo_resource, type: :boolean, default: true unless ARGV.include?("--without_resource")
    end
  end
end
