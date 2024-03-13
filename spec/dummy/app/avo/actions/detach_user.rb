class Avo::Actions::DetachUser < Avo::BaseAction
  self.name = "Detach User"
  self.visible = -> do
    parent_resource.present?
  end

  # def fields
  #   # Add Action fields here
  # end

  def handle(query:, fields:, current_user:, resource:, **args)
    query.each do |record|
      record.projects.clear
    end
  end
end
