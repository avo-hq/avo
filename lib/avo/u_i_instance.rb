# frozen_string_literal: true

class Avo::UIInstance
  unless defined?(MISSING_COMPONENT_CLASS)
    MISSING_COMPONENT_CLASS = "Avo::ComponentMissingComponent"
  end

  # Cache for resolved component classes to avoid repeated classify/constantize calls
  @component_cache = {}
  @cache_mutex = Mutex.new

  class << self
    def resolve_component(method)
      # Check cache first (thread-safe read)
      cached = @component_cache[method]
      return cached if cached

      # Cache miss - resolve and store (thread-safe write)
      @cache_mutex.synchronize do
        # Double-check after acquiring lock
        return @component_cache[method] if @component_cache[method]

        component_class = "#{method.to_s.delete_suffix("_component")}_component"
        full_class_name = "Avo::#{component_class.classify}"
        ui_full_class_name = "Avo::UI::#{component_class.classify}"

        resolved = if Object.const_defined?(full_class_name)
          full_class_name.constantize
        elsif Object.const_defined?(ui_full_class_name)
          ui_full_class_name.constantize
        end

        @component_cache[method] = resolved
      end
    end

    def clear_cache!
      @cache_mutex.synchronize { @component_cache.clear }
    end

    # Used in parent apps like this `ui.panel(...)`
    # @method: string "panel"
    # @return: (method: String) -> Component
    def method_missing(method, *args, **kwargs, &block)
      component_class = resolve_component(method)

      if component_class
        component_class.new(*args, **kwargs, &block)
      else
        MISSING_COMPONENT_CLASS.safe_constantize.new(component_name: method)
      end
    end

    def respond_to_missing?(method, include_private = false)
      # Since method_missing always handles any method call (either with a real component
      # or falling back to MISSING_COMPONENT_CLASS), respond_to? should return true
      true
    end
  end
end
