module Avo
  class ArrayController < Avo::BaseController
    def set_query
      @query ||= @resource.fetch_records
    end

    private

    # Fetching builds the model class with an accessor per attribute, so a new record can be filled.
    def set_record_to_fill
      @resource.fetch_records
      super
    end
  end
end
