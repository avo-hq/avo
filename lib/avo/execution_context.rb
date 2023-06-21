module Avo
  class ExecutionContext
    attr_accessor :target, :context, :params, :view_context, :current_user, :request, :include, :main_app, :avo

    def initialize(**args)
      # Extend the class with custom modules if required.
      if args[:include].present?
        args[:include].each do |mod|
          self.class.send(:include, mod)
        end
      end

      # If target doesn't respond to call, we don't need to initialize the others attr_accessors.
      return unless (@target = args[:target]).respond_to? :call

      args.except(:target).each do |key, value|
        singleton_class.class_eval { attr_accessor key }
        instance_variable_set("@#{key}", value)
      end

      # Set defaults on not initialized accessors
      @context ||= Avo::App.context
      @params ||= Avo::App.params
      @view_context ||= Avo::App.view_context
      @current_user ||= Avo::App.current_user
      @request ||= view_context.request
      @main_app ||= view_context.main_app
      @avo ||= view_context.avo
    end

    # Return target if target is not callable, otherwise, execute target on this instance context
    def handle
      target.respond_to?(:call) ? instance_exec(&target) : target
    end
  end
end
