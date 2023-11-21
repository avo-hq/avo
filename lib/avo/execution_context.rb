module Avo
  class ExecutionContext
    include Avo::Concerns::HasHelpers

    attr_accessor :target, :context, :params, :view_context, :current_user, :request, :include, :main_app, :avo, :locale

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
      @context ||= Avo::Current.context
      @current_user ||= Avo::Current.user
      @params ||= Avo::Current.params
      @request ||= Avo::Current.request
      @view_context ||= Avo::Current.view_context
      @locale ||= Avo::Current.locale
      @main_app ||= @view_context&.main_app
      @avo ||= @view_context&.avo
    end

    delegate :result, to: :card
    delegate :authorize, to: Avo::Services::AuthorizationService

    # Return target if target is not callable, otherwise, execute target on this instance context
    def handle
      target.respond_to?(:call) ? instance_exec(&target) : target
    end
  end
end
