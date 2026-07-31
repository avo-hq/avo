require_dependency "avo/base_controller"

module Avo
  class AssociationsController < BaseController
    before_action :set_record, only: [:show, :index, :new, :create, :destroy]
    before_action :set_related_resource_name
    before_action :set_related_resource, only: [:show, :index, :new, :create, :destroy]
    before_action :set_related_authorization
    before_action :set_reflection_field
    before_action :set_related_record, only: [:show]
    before_action :set_reflection
    before_action :set_attachment_class, only: [:show, :index, :new, :create, :destroy]
    before_action :set_attachment_resource, only: [:show, :index, :new, :create, :destroy]
    before_action :set_attachment_record, only: [:create, :destroy]
    before_action :set_attach_fields, only: [:new, :create]
    before_action :authorize_index_action, only: :index
    before_action :authorize_attach_action, only: [:new, :create]
    before_action :authorize_detach_action, only: :destroy

    layout :choose_layout

    def index
      @parent_resource = @resource.dup
      @resource = @related_resource
      @parent_record = @parent_resource.find_record(params[:id], params: params)
      @parent_resource.hydrate(record: @parent_record)

      # When array field the records are fetched from the field block, from the parent record or from the resource def records
      # When other field type, like has_many the @query is directly fetched from the parent record
      # Don't apply policy on array type since it can return an array of hashes where `.all` and other methods used on policy will fail.
      @query = if @field.type == "array"
        @resource.fetch_records(Avo::ExecutionContext.new(target: @field.block, record: @parent_record).handle || @parent_record.try(@field.id))
      else
        association_query_scope(
          parent_resource: @parent_resource,
          parent_record: @parent_record,
          association_name: association_from_params,
          authorization: @related_authorization,
          resource: @resource,
          field_association_name: params[:related_name]
        )
      end

      super
    end

    def show
      @parent_resource, @parent_record = @resource, @record

      @resource, @record = @related_resource, @related_record

      super
    end

    def new
      @resource.hydrate(record: @record)

      if @field.present? && !@field.is_searchable?
        query = @related_authorization.apply_policy @attachment_class

        # Add the association scope to the query scope
        if @field.attach_scope.present?
          query = Avo::ExecutionContext.new(target: @field.attach_scope, query: query, parent: @record).handle
        end

        @options = if attach_using_checkbox_list?
          checkbox_list_options(query)
        else
          select_options(query)
        end
      end

      @url = Avo::Services::URIService.parse(avo.root_url.to_s)
        .append_paths("resources", params[:resource_name], params[:id], params[:related_name])
        .append_query(
          {
            view: @resource&.view&.to_s,
            for_attribute: @field&.try(:for_attribute)
          }.compact
        )
        .to_s
    end

    def create
      if create_association
        create_success_action
      else
        create_fail_action
      end
    end

    def create_association
      association_name = BaseResource.valid_association_name(@record, association_from_params)

      if attachment_records.empty?
        @record.errors.add(:base, t("avo.choose_an_option"))
        return false
      end

      perform_action_and_record_errors do
        @record.transaction do
          attachment_records.each do |attachment_record|
            attach_record(association_name, attachment_record)
          end
        end
      end
    end

    def destroy
      association_name = BaseResource.valid_association_name(@record, @field.for_attribute || params[:related_name])

      if through_reflection?
        join_record&.destroy!
      elsif has_many_reflection?
        @record.send(association_name).delete @attachment_record
      else
        @record.send(:"#{association_name}=", nil)
      end

      destroy_success_action
    end

    private

    def set_reflection
      @reflection = @record.class.try(:reflect_on_association, association_from_params)

      return if @reflection.blank? && @field.type == "array"

      # Ensure inverse_of is present on STI
      if !@record.class.descends_from_active_record? && @reflection.inverse_of.blank? && Rails.env.development?
        raise "Avo relies on the 'inverse_of' option to establish the inverse association and perform some specific logic.\n" \
          "Please configure the 'inverse_of' option for the '#{@reflection.macro} :#{@reflection.name}' association " \
          "in the '#{@reflection.active_record.name}' model."
      end
    end

    def set_attachment_class
      # @reflection is nil whe using an Array field.
      @attachment_class = @reflection&.klass
    end

    def set_attachment_resource
      @attachment_resource = @field.use_resource || (Avo.resource_manager.get_resource_by_model_class @attachment_class)
    end

    def set_attachment_record
      if action_name == "create"
        @attachment_records = attachment_ids.map do |id|
          @related_resource.find_record id, params: params
        end
        @attachment_record = @attachment_records.first
      else
        @attachment_record = @related_resource.find_record attachment_id, params: params
      end
    end

    def set_reflection_field
      @field = find_association_field(resource: @resource, association: @related_resource_name)
      @field.hydrate(resource: @resource, record: @record, view: Avo::ViewInquirer.new(:new))
    rescue
    end

    def attachment_id
      params[:related_id] || params.dig(:fields, :related_id)
    end

    def attachment_ids
      Array(attachment_id).reject(&:blank?)
    end

    def attachment_records
      @attachment_records ||= attachment_ids.map do |id|
        @related_resource.find_record id, params: params
      end
    end

    def reflection_class
      if @reflection.is_a?(ActiveRecord::Reflection::ThroughReflection)
        @reflection.through_reflection.class
      else
        @reflection.class
      end
    end

    def authorize_if_defined(method, record = @record)
      return unless Avo.configuration.authorization_enabled?

      @authorization.set_record(record)

      if @authorization.has_method?(method.to_sym)
        @authorization.authorize_action method.to_sym
      elsif Avo.configuration.explicit_authorization
        raise Avo::NotAuthorizedError.new
      end
    end

    def authorize_index_action
      authorize_if_defined "view_#{@field.id}?"
    end

    def authorize_attach_action
      authorize_if_defined "attach_#{@field.id}?"
    end

    def authorize_detach_action
      authorize_if_defined "detach_#{@field.id}?", @attachment_record
    end

    def set_related_authorization
      @related_authorization = if @related_resource.present?
        @related_resource.authorization(user: _current_user)
      else
        Services::AuthorizationService.new _current_user
      end
    end

    def association_from_params
      @field&.for_attribute || params[:related_name]
    end

    def source_foreign_key
      @reflection.source_reflection.foreign_key
    end

    # Resolve the join record through the (scoped) through association rather
    # than an unscoped `find_by` on the join model. When a pair of records is
    # linked more than once, the association's scope is the only thing that
    # tells one join row from another — `-> { where level: :admin }` picking the
    # admin row out of a user's memberships, say. An unscoped lookup matches on
    # the two foreign keys alone and destroys whichever row it happens to hit.
    #
    # A `has_many :through` narrows the association down to the record being
    # detached. A `has_one :through` already *is* that record, so it only has to
    # be checked against the one named in the URL — otherwise a stale page or a
    # double detach would destroy whatever is currently attached.
    def join_record
      return through_association.find_by(source_foreign_key => @attachment_record.id) if @reflection.collection?

      record = through_association
      record if record.present? && record[source_foreign_key] == @attachment_record.id
    end

    # The through association itself: a collection proxy for `has_many :through`,
    # the join record (or nil) for `has_one :through`. Reading it rather than the
    # join model is what keeps the association's scope in play.
    def through_association
      @record.send(@reflection.through_reflection.name)
    end

    def has_many_reflection?
      reflection_class.in? [
        ActiveRecord::Reflection::HasManyReflection,
        ActiveRecord::Reflection::HasAndBelongsToManyReflection
      ]
    end

    def through_reflection?
      @reflection.instance_of? ActiveRecord::Reflection::ThroughReflection
    end

    # Rails uses ThroughReflection for both `has_many :through` and
    # `has_one :through`, so `through_reflection?` alone can't tell a collection
    # from a singular association.
    def collection_through_reflection?
      through_reflection? && @reflection.collection?
    end

    def additional_params
      @additional_params ||= params[:fields].slice(*@attach_fields&.map(&:id))
    end

    def set_attach_fields
      @attach_fields = if @field.attach_fields.present?
        Avo::FieldsExecutionContext.new(target: @field.attach_fields)
          .detect_fields
          .items_holder
          .items
      end
    end

    def attach_record(association_name, attachment_record)
      # Hand-build the join record only when attach fields have to land before
      # the insert: `<<` saves immediately, and a join model that validates one
      # of those columns (StorePatron#review) fails before we could fill it.
      # Otherwise prefer `<<` — it fills in the polymorphic source type and
      # handles composite primary keys, neither of which we do by hand.
      #
      # Collection-only, and not merely by preference: it builds *through* the
      # association, and `new` is a collection proxy method. A singular through
      # also needs replace semantics, which only assignment gives — building a
      # second join record would leave the association with two rows to pick
      # from.
      if collection_through_reflection? && additional_params.present?
        new_join_record(attachment_record).save!
      elsif has_many_reflection? || collection_through_reflection?
        @record.send(association_name) << attachment_record
      else
        @record.send(:"#{association_name}=", attachment_record)
        @record.save!

        persist_join_record if through_reflection?
      end
    end

    # A singular through association owns exactly one join record, and the
    # assignment in `attach_record` already created or replaced it through the
    # (scoped) through association.
    def persist_join_record
      through_record = through_association

      return if through_record.blank?

      # Fill the attach fields onto that row instead of inserting a second one
      # that the association's scope wouldn't even match.
      @resource.fill_record(through_record, additional_params, fields: @attach_fields) if additional_params.present?

      # Rails writes the join record with `create`, which returns an unsaved
      # record instead of raising when it's invalid. Without this `save!` the
      # attach would report success while nothing was written.
      through_record.save!
    end

    # Build the join record *through* the (scoped) through association, so Rails
    # stamps the scope's attributes on it — `-> { where level: :admin }` writing
    # `level` — along with the through foreign key. Building it on the join
    # model instead writes the two foreign keys and nothing else, so a scoped
    # association reports a successful attach and then doesn't match the row it
    # just wrote. The `<<` arm below already goes through the association; this
    # only differs in having attach fields to fill.
    def new_join_record(attachment_record)
      @resource.fill_record(
        through_association.new(source_foreign_key => attachment_record.id),
        additional_params,
        fields: @attach_fields
      )
    end

    def create_success_action
      flash[:notice] = t("avo.attachment_class_attached", attachment_class: @related_resource.name)

      respond_to do |format|
        if params[:turbo_frame].present?
          format.turbo_stream { render turbo_stream: reload_frame_turbo_streams }
        else
          format.html { redirect_back fallback_location: resource_view_response_path }
        end
      end
    end

    def reload_frame_turbo_streams
      turbo_streams = super

      # We want to close the modal if the user wants to add just one record
      turbo_streams << turbo_stream.avo_close_modal if params[:button] != "attach_another"

      turbo_streams
    end

    def create_fail_action
      flash[:error] = t("avo.attachment_failed", attachment_class: @related_resource.name)

      respond_to do |format|
        format.turbo_stream {
          render turbo_stream: turbo_stream.append("alerts", partial: "avo/partials/all_alerts")
        }
      end
    end

    def destroy_success_action
      flash[:notice] = t("avo.attachment_class_detached", attachment_class: @attachment_class)

      respond_to do |format|
        if params[:turbo_frame].present?
          format.turbo_stream do
            render turbo_stream: reload_frame_turbo_streams
          end
        else
          format.html { redirect_to params[:referrer] || resource_view_response_path }
        end
      end
    end

    def select_options(query)
      lookup_list_limit = Avo.configuration.associations[:lookup_list_limit]

      query.all.limit(lookup_list_limit).map do |record|
        [@attachment_resource.new(record: record).record_title, record.to_param]
      end.tap do |options|
        options << t("avo.more_records_available") if options.size == lookup_list_limit
      end
    end

    def checkbox_list_options(query)
      lookup_list_limit = Avo.configuration.associations[:lookup_list_limit]

      query.all.limit(lookup_list_limit).map do |record|
        checkbox_list_option(record)
      end.tap do |options|
        if options.size == lookup_list_limit
          options << {title: t("avo.more_records_available"), hint: true}
        end
      end
    end

    def checkbox_list_option(record)
      resource = @attachment_resource.new(record:, view: Avo::ViewInquirer.new(:new), params:)
      search_item = (@attachment_resource.fetch_search(:item, record:) || {}).with_indifferent_access
      title = search_item[:title] || resource.record_title

      {
        id: record.to_param,
        title:,
        image_url: search_item[:image_url] || search_item[:avatar_url] || checkbox_list_avatar(resource),
        image_format: search_item[:image_format],
        image_alt: search_item[:image_alt] || search_item[:avatar_alt],
        description: search_item[:description]
      }.compact
    end

    def checkbox_list_avatar(resource)
      resource.avatar.value if resource.avatar.present?
    end

    def attach_using_checkbox_list?
      @field.respond_to?(:attach_using_checkbox_list?) && @field.attach_using_checkbox_list?
    end

    def pagination_key
      @pagination_key ||= "#{@parent_resource.class.to_s.parameterize}.has_many.#{@related_resource.class.to_s.parameterize}"
    end

    def set_pagination_params
      set_page_param
      set_per_page_param
    end

    def set_page_param
      # avo-resources-project.has_many.avo-resources-user.page
      page_key = "#{pagination_key}.page"

      @index_params[:page] = if Avo.configuration.session_persistence_enabled?
        session[page_key] = params[:page] || session[page_key] || 1
      else
        params[:page] || 1
      end
    end

    def set_per_page_param
      # avo-resources-project.has_many.avo-resources-user.per_page
      per_page_key = "#{pagination_key}.per_page"

      @index_params[:per_page] = if Avo.configuration.session_persistence_enabled?
        session[per_page_key] = params[:per_page] || session[per_page_key] || Avo.configuration.via_per_page
      else
        params[:per_page] || Avo.configuration.via_per_page
      end
    end
  end
end
