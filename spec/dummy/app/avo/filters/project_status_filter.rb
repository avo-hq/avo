class Avo::Filters::ProjectStatusFilter < Avo::Filters::BooleanFilter
  self.name = "Status"

  def apply(request, query, values)
    query.where(status: values.select { |_k, v| v }.keys)
  end

  def options
    {
      "Done" => "Done",
      "loading" => "Loading",
      "running" => "Running",
      "waiting" => "Waiting",
      "Hold On" => "Hold On",
      "closed" => "Closed",
      "rejected" => "Rejected",
      "failed" => "Failed",
      "user_reject" => "User Reject"
    }
  end
end
