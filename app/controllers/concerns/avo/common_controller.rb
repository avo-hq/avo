module Avo
  module CommonController
    def default_url_options
      result = super.dup
      result[:force_locale] = params[:force_locale]

      extra_default_url_options.each do |param_name|
        result[param_name] = params[param_name]
      end

      result.compact
    end

    def extra_default_url_options
      block_or_array = Avo.configuration.default_url_options
      if block_or_array.respond_to?(:call)
        instance_eval(&block_or_array)
      else
        block_or_array
      end
    end
  end
end
