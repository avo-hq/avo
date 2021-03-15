class Generators::ResourceGenerator < ::Rails::Generators::NamedBase
  source_root File.expand_path('templates', __dir__)

  namespace 'avo:resource'

  def create
    template 'resource/%singular_name%.tt', "app/avo/resources/#{singular_name}.rb"
    template 'resource/%plural_name%_controller.tt', "app/controllers/avo/#{controller_name}.rb"

    # Show a warning if the model doesn't exists
    say("We couldn't find the #{class_name} model in your codebase. You should have one present for Avo to display the resource.", :yellow) unless current_models.include? class_name
  end

  def controller_name
    "#{plural_name}_controller"
  end

  def current_models
    ActiveRecord::Base.connection.tables.map do |model|
      model.capitalize.singularize.camelize
    end
  end
end
