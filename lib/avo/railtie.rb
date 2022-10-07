require 'rails/railtie'

module ActiveModel
  class Avo::Railtie < Rails::Railtie
    generators do |app|
      Rails::Generators.configure! app.config.generators
      require_relative '../generators/model_generator'
    end
  end
end
