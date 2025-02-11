module Avo
  class ArrayController < BaseController
    def set_query
      @query ||= @resource.fetch_records
    end
  end
end
