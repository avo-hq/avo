module Avo
  # = Avo Execution Context
  #
  # The ExecutionContext class is used to evaluate blocks in isolation.
  class ExecutionContext
    include Avo::Concerns::HasHelpers

    attr_accessor :target, :context, :params, :view_context, :current_user, :request, :include, :main_app, :avo, :locale

    delegate_missing_to :@view_context

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

    # Executes the target and returns the result.
    # It takes in a target which usually is a block. If it's something else, it will return it.
    #
    # It automatically has access to the view context, current user, request, main app, avo, locale, and params.
    # It also has a +delegate_missing_to+ which allows it to delegate missing methods to the view context for a more natural experience.
    # You may pass extra arguments to the initialize method to have them available in the block that will be executed.
    # You may pass extra modules to extend the class with.
    #
    # ==== Examples
    #
    # ===== Normal use
    #
    #   Avo::ExecutionContext.new(target: -> { "Hello, world!" }).handle
    #   => "Hello, world!"
    #
    # ===== Providing a record
    #
    #   Avo::ExecutionContext.new(target: -> { record.name }, record: @record).handle
    #   => "John Doe"
    #
    # ===== Providing a module
    #
    # This will include the SanitizeHelper module in the class and so have the +sanitize+ method available.
    #
    #   Avo::ExecutionContext.new(target: -> { sanitize "<script>alert('be careful');</script>#{record.name}" } record: @record, include: [ActionView::Helpers::SanitizeHelper]).handle
    #   => "John Doe"
    def handle
      target.respond_to?(:call) ? instance_exec(&target) : target
    end
  end
end
