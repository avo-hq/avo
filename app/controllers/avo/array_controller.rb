module Avo
  class ArrayController < Avo::BaseController
    def set_query
      @query ||= @resource.fetch_records
    end
  end
end
