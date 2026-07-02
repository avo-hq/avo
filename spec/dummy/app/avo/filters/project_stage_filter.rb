class Avo::Filters::ProjectStageFilter < Avo::Filters::BooleanFilter
  self.name = "Stage"

  def apply(request, query, values)
    query.where(stage: values.select { |_k, v| v }.keys)
  end

  def options
    Project.stages.transform_keys(&:to_s)
  end
end
