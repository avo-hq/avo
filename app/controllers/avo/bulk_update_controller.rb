require_dependency "avo/application_controller"

module Avo
  # Renders and handles the per-resource bulk-update slide-out.
  #
  # Show-path responsibilities (Unit 5a):
  #   1. Decode the selection (either `avo_resource_ids` or the encrypted index query).
  #   2. Verify `bulk_update_enabled?` for the resource (403 otherwise).
  #   3. Enforce the cap BEFORE materializing the query (LIMIT-bounded count).
  #   4. Filter to the authorized subset via per-record `update?`.
  #   5. Enforce N >= 2 server-side.
  #   6. Compute per-field "status notices" (all-share / sample-list / count-only).
  #   7. Render the slide-out via `Avo::SlideOverComponent`.
  #
  # Handle-path responsibilities (Unit 5b):
  #   1. Derive the server-side allowlist from `bulk_updatable_field_ids` -
  #      the SAME single source of truth used to render the form.
  #   2. Drop blank values (defense against JS-fails-to-disable AND against
  #      ActiveRecord's "" -> nil type-casting on date/integer/decimal/boolean).
  #   3. Drop the Boolean tri-state `Unchanged` sentinel (Unit 4).
  #   4. Re-run per-record `update?` (the POSTed IDs may have been tampered).
  #   5. EITHER invoke the optional override (via `Avo::ExecutionContext`) and
  #      validate its returned shape, OR run the default best-effort write loop.
  #   6. Emit `avo.bulk_update.submit` notification - KEYS ONLY (no values, no
  #      Rails validation messages) to prevent PII leak through subscribers.
  #   7. Respond with a Turbo Stream: full-success closes the slide-out and
  #      per-row replaces on the user's visible page; partial-failure replaces
  #      the slide-out body with the FailureListComponent; total failure shows
  #      an error banner.
  #
  # There is NO fast-path for retry: every POST (initial or retry) runs the
  # full `set_query` + cap + per-record `update?` filter. The hidden
  # `avo_resource_ids` input is untrusted on every request.
  #
  # Encryption purpose tag is `:bulk_update_select_all` (NOT Actions' `:select_all`)
  # so an encrypted query lifted from an Actions URL is rejected at decrypt.
  # The Marshal payload also embeds `actor_id` so an encrypted query lifted from
  # User A and replayed by User B is rejected at the actor-binding check.
  class BulkUpdateController < ApplicationController
    before_action :set_resource_name, :set_resource
    before_action :detect_fields, only: [:show, :handle]
    before_action :set_query, only: [:show, :handle]

    layout :choose_layout

    def show
      return forbid_unsupported_resource unless @resource.bulk_update_enabled?

      @bulk_view = Avo::ViewInquirer.new(:bulk_edit)
      @resource.hydrate(view: @bulk_view, user: _current_user, params: params)

      # 1. LIMIT-bounded cap check BEFORE materialization. Wide queries (e.g.
      #    select-all-matching against a permissive filter) can match millions
      #    of rows; loading them into memory just to discover they exceed the
      #    cap is a DoS vector.
      cap = @resource.bulk_update_max_records
      capped_count = limit_bounded_count(@query, cap + 1)

      if capped_count > cap
        render_cap_exceeded_frame(total: capped_count, max: cap)
        return
      end

      # 2. Materialize the (now known-bounded) records.
      records = materialize_records(@query, cap)
      original_count = records.size

      # 3. Filter to authorized subset via per-record update? check.
      authorized = records.select { |record| authorized_to_update?(record) }
      authorized_count = authorized.size

      # 4. K == 0 -> "no records editable" frame.
      if authorized_count.zero?
        render_no_records_editable_frame(total: original_count)
        return
      end

      # 5. N >= 2 server-side enforcement (UI hides the button at N=1 but this
      #    defends against direct URL access).
      if authorized_count < 2
        render_n_too_small_frame(authorized: authorized_count, total: original_count)
        return
      end

      @authorized_records = authorized
      @authorized_count = authorized_count
      @original_count = original_count
      @field_notices = compute_field_notices(authorized)

      render :show
    end

    # POST handler. Runs the bulk write best-effort.
    #
    # Two write paths:
    #   * Override (`handle_bulk_update_callable`): framework re-runs per-record
    #     `update?` BEFORE invoking, validates the returned shape strictly, and
    #     emits the audit event using the override's reported outcomes.
    #   * Default loop: per-record `update?` re-check inside the loop,
    #     `@resource.fill_record(record, filtered)`, `record.save!` with rescue
    #     for `RecordInvalid` (reason `:validation`) and `StaleObjectError`
    #     (reason `:concurrent_modification`).
    def handle
      return forbid_unsupported_resource unless @resource.bulk_update_enabled?

      @bulk_view = Avo::ViewInquirer.new(:bulk_edit)
      @resource.hydrate(view: @bulk_view, user: _current_user, params: params)

      # Re-run cap + authorization on the POST payload. There is NO fast-path
      # for retry: every POST runs the full filter. The hidden
      # `avo_resource_ids` input is attacker-controlled.
      cap = @resource.bulk_update_max_records
      capped_count = limit_bounded_count(@query, cap + 1)
      if capped_count > cap
        render_cap_exceeded_frame(total: capped_count, max: cap)
        return
      end

      records = materialize_records(@query, cap)
      @original_count = records.size

      # First-pass authz filter (open-time equivalent). The default loop
      # re-checks per-record below; the override path uses this subset directly.
      authorized = records.select { |record| authorized_to_update?(record) }
      @authorized_count = authorized.size

      # Derive the server-side allowlist via the SAME method the show path
      # uses to render the form fields. Single source of truth (R17).
      allowed_ids = @resource.bulk_updatable_field_ids(current_user: _current_user)
      filtered = filter_submitted_attributes(allowed_ids)

      result =
        if filtered.empty?
          # Empty submission: skip the per-record loop entirely. The audit event
          # STILL fires below with `updated_ids: []` and `attempted_keys: []`
          # (the "minimum floor" framing in the plan: subscribers can filter on
          # the empty shape).
          {updated_ids: [], failed: []}
        elsif @resource.handle_bulk_update_callable
          run_override(authorized: authorized, attributes: filtered)
        else
          run_default_loop(authorized: authorized, attributes: filtered)
        end

      emit_audit_event(filtered, result)

      respond_with_result(result, filtered)
    end

    private

    def set_query
      @query = if bulk_update_params[:fields]&.dig(:avo_selected_all) == "true"
        decrypted_index_query
      else
        find_records_from_resource_ids
      end
    end

    def find_records_from_resource_ids
      ids = bulk_update_params[:fields]&.dig(:avo_resource_ids)&.to_s&.split(",") || []
      return @resource.class.find_scope.none if ids.empty?

      @resource.class.find_scope.where(@resource.class.model_class.primary_key => ids)
    end

    def bulk_update_params
      @bulk_update_params ||= params.permit(
        :resource_name, :authenticity_token, :current_page_ids, fields: {}
      )
    end

    # Decrypt the encrypted index query.
    #
    # Two defenses (vs Actions' shared `:select_all`):
    #   (a) Distinct purpose tag (`:bulk_update_select_all`) - cross-feature
    #       replay from an Actions URL fails at decryption.
    #   (b) Actor binding - the Marshal payload is a Hash `{ query:, actor_id: }`;
    #       cross-user replay (User A's encrypted query POSTed as User B) returns 403.
    def decrypted_index_query
      return @resource.class.find_scope.none if encrypted_query.blank? || encrypted_query == "select_all_disabled"

      payload = Avo::Services::EncryptionService.decrypt(
        message: encrypted_query,
        purpose: :bulk_update_select_all,
        serializer: Marshal
      )

      verify_actor_binding!(payload)

      extract_query_from_payload(payload)
    rescue ActiveSupport::MessageEncryptor::InvalidMessage,
      ActiveSupport::MessageVerifier::InvalidSignature
      # Wrong purpose / tampered ciphertext / payload encrypted under a
      # different key. Surface as 403 with a generic message; no IDs leak.
      render_forbidden(I18n.t("avo.not_authorized")) and return nil
    end

    # The encrypted payload is expected to be `{ query: <Relation>, actor_id: <id> }`.
    # We compare `actor_id` to `current_user&.id` and 403 on mismatch.
    def verify_actor_binding!(payload)
      return if performed?

      actor_id = payload.is_a?(Hash) ? payload[:actor_id] : nil
      current_id = _current_user&.id

      if actor_id != current_id
        render_forbidden(I18n.t("avo.not_authorized"))
      end
    end

    def extract_query_from_payload(payload)
      return @resource.class.find_scope.none if performed?

      if payload.is_a?(Hash)
        payload[:query]
      else
        payload
      end
    end

    def encrypted_query
      @encrypted_query ||= bulk_update_params[:fields]&.dig(:avo_index_query)
    end

    # Use a LIMIT-bounded count to enforce the cap before materializing. For
    # ActiveRecord relations this issues `SELECT COUNT(*) FROM (... LIMIT n)`.
    # For plain arrays we just measure.
    def limit_bounded_count(query, limit)
      if query.respond_to?(:limit) && query.respond_to?(:count)
        query.limit(limit).count
      else
        Array(query).take(limit).size
      end
    rescue NoMethodError
      Array(query).take(limit).size
    end

    def materialize_records(query, limit)
      if query.respond_to?(:limit)
        query.limit(limit).to_a
      else
        Array(query).take(limit)
      end
    end

    # Per-record update? check. In OSS this is a no-op shim (always true);
    # avo-pro plugs in the real policy. The shape mirrors
    # base_application_controller.rb:216-220.
    def authorized_to_update?(record)
      @resource.authorization(user: _current_user)
        .set_record(record)
        .authorize_action(:update, raise_exception: false)
    end

    # For each bulk-updatable field, group authorized records by the value of
    # that field. Produces a hash keyed by field id (Symbol):
    #
    #   { stage: { mode: :all_share, value: "success", count: 5 },
    #     priority: { mode: :sample_list, values: ["high", "low"], distinct_count: 2, count: 5 },
    #     notes: { mode: :count_only, distinct_count: 47, count: 47 } }
    def compute_field_notices(records)
      threshold = @resource.bulk_update_sample_threshold
      total = records.size

      bulk_field_ids.each_with_object({}) do |field_id, acc|
        distinct_values = distinct_values_for(records, field_id)

        acc[field_id] = if distinct_values.size == 1
          {mode: :all_share, value: distinct_values.first, count: total}
        elsif distinct_values.size <= threshold
          {mode: :sample_list, values: distinct_values, distinct_count: distinct_values.size, count: total}
        else
          {mode: :count_only, distinct_count: distinct_values.size, count: total}
        end
      end
    end

    def distinct_values_for(records, field_id)
      records.map { |r| r.respond_to?(field_id) ? r.send(field_id) : nil }.uniq
    end

    def bulk_field_ids
      @bulk_field_ids ||= @resource.bulk_updatable_field_ids(current_user: _current_user)
    end

    helper_method :bulk_field_ids, :bulk_update_params

    # ---- handle-path helpers --------------------------------------------------

    # Slice the submitted `fields` hash down to allowlisted attribute keys,
    # excluding framework keys (avo_resource_ids / avo_selected_all /
    # avo_index_query), then drop blanks AND drop the boolean Unchanged sentinel.
    def filter_submitted_attributes(allowed_ids)
      submitted = bulk_update_params[:fields].to_h.reject do |k, _|
        FRAMEWORK_KEYS.include?(k.to_s)
      end

      allowed_set = allowed_ids.map(&:to_s).to_set
      filtered = submitted.select { |k, _| allowed_set.include?(k.to_s) }

      # Blank-skip pass (v1 floor against bulk-clearing).
      filtered = filtered.reject { |_, v| v.blank? }

      # Boolean tri-state sentinel ("Unchanged"). Dirty-tracking client should
      # not send it, but defense-in-depth.
      filtered.reject { |_, v| v == Avo::Fields::BooleanField::EditComponent::BULK_EDIT_UNCHANGED }
    end

    FRAMEWORK_KEYS = %w[avo_resource_ids avo_selected_all avo_index_query].freeze

    # Run the optional override through Avo::ExecutionContext. The framework:
    #   - re-runs per-record `update?` BEFORE invoking (override never sees
    #     an unauthorized record);
    #   - validates the returned shape and raises ArgumentError on mismatch -
    #     a misconfigured override fails LOUDLY, no audit event fires.
    def run_override(authorized:, attributes:)
      authorized_for_override = authorized.select { |record| authorized_to_update?(record) }

      raw = Avo::ExecutionContext.new(
        target: @resource.handle_bulk_update_callable,
        records: authorized_for_override,
        attributes: attributes,
        current_user: _current_user
      ).handle

      validate_override_result!(raw)

      {
        updated_ids: Array(raw[:updated_ids]),
        failed: Array(raw[:failed]).map { |f| f.is_a?(Hash) ? f : {id: f, reason: :unknown} }
      }
    end

    def validate_override_result!(raw)
      unless raw.is_a?(Hash) && raw.key?(:updated_ids) && raw.key?(:failed)
        raise ArgumentError, "handle_bulk_update override on #{@resource.class} must return a Hash with :updated_ids (Array) and :failed (Array of Hash with :id, :reason, optional :message). Got: #{raw.inspect}"
      end

      unless raw[:updated_ids].is_a?(Array) && raw[:failed].is_a?(Array)
        raise ArgumentError, "handle_bulk_update override on #{@resource.class} must return :updated_ids and :failed as Arrays. Got updated_ids=#{raw[:updated_ids].class}, failed=#{raw[:failed].class}"
      end

      raw[:failed].each do |entry|
        unless entry.is_a?(Hash) && entry.key?(:id) && entry.key?(:reason)
          raise ArgumentError, "handle_bulk_update override on #{@resource.class} returned a failed entry without :id and :reason. Got: #{entry.inspect}"
        end
      end
    end

    # Default best-effort write loop. Per-record `update?` re-check, fill, save!,
    # with rescue for validation and concurrent-modification.
    def run_default_loop(authorized:, attributes:)
      updated = []
      failed = []

      authorized.each do |record|
        unless authorized_to_update?(record)
          failed << {id: record.id, reason: :unauthorized_at_write}
          next
        end

        begin
          # NOTE: do NOT call cast_nullable on this path. cast_nullable lives in
          # BaseController#update; fill_record itself does not call it. The
          # bulk-update path uses blank-skip (above) as the equivalent floor.
          @resource.fill_record(record, attributes)
          record.save!
          updated << record.id
        rescue ActiveRecord::RecordInvalid => e
          failed << {
            id: record.id,
            reason: :validation,
            message: e.record.errors.full_messages.join(", ")
          }
        rescue ActiveRecord::StaleObjectError
          failed << {id: record.id, reason: :concurrent_modification}
        end
      end

      {updated_ids: updated, failed: failed}
    end

    # Emit the audit event. KEYS ONLY for `attempted_keys`; failed entries are
    # stripped of `:message` before the payload is built (Rails validation
    # messages embed attribute values, which would defeat the no-values
    # invariant).
    def emit_audit_event(filtered, result)
      audit_failed = result[:failed].map { |f| f.slice(:id, :reason) }

      ActiveSupport::Notifications.instrument(
        "avo.bulk_update.submit",
        actor_id: _current_user&.id,
        resource: @resource.class.to_s,
        updated_ids: result[:updated_ids],
        failed: audit_failed,
        attempted_keys: filtered.keys.map(&:to_sym)
      )
    end

    # Build the Turbo Stream response. Per-row replace is capped to
    # `current_page_ids` (Unit 3's hidden input). Off-page updated rows refresh
    # on the user's next navigation; the flash names the off-page count.
    def respond_with_result(result, filtered)
      updated_ids = result[:updated_ids]
      failed = result[:failed]
      total_updated = updated_ids.size

      visible_ids = current_page_ids_intersection
      on_page_updated = visible_ids ? (updated_ids.map(&:to_s) & visible_ids) : updated_ids.map(&:to_s)
      off_page_count = total_updated - on_page_updated.size

      respond_to do |format|
        format.turbo_stream do
          if failed.empty?
            flash[:notice] = success_flash(total: total_updated, off_page: off_page_count)
            render turbo_stream: [
              turbo_stream.avo_close_slide_over,
              turbo_stream.avo_flash_alerts,
              *per_row_replaces(on_page_updated)
            ]
          else
            flash[:warning] = partial_flash(updated: total_updated, failed: failed.size, total: total_updated + failed.size)
            render turbo_stream: [
              turbo_stream.replace(
                "bulk-update-form-body",
                partial: "avo/bulk_update/failure_list_panel",
                locals: {
                  failed: failed,
                  resource: @resource,
                  bulk_field_ids: bulk_field_ids,
                  authorized_count: @authorized_count,
                  original_count: @original_count,
                  filtered: filtered,
                  current_page_ids: visible_ids
                }
              ),
              turbo_stream.avo_flash_alerts,
              *per_row_replaces(on_page_updated)
            ]
          end
        end
      end
    end

    # Per-row Turbo Stream replace for the user's currently-visible page only.
    # Bounds the response body to ~page_size fragments regardless of batch size.
    #
    # The frame ID follows the convention `<resource_model_key>_<id>_row`. If
    # the host page uses a different convention the replace is a no-op
    # (graceful degradation). Off-page rows refresh on the user's next
    # navigation; the flash names the off-page count.
    def per_row_replaces(ids)
      ids.map do |id|
        turbo_stream.replace(
          "#{@resource.model_key}_#{id}_row",
          partial: "avo/bulk_update/row_replace_placeholder",
          locals: {id: id, resource: @resource}
        )
      end
    end

    def current_page_ids_intersection
      raw = params[:current_page_ids].to_s
      return nil if raw.blank?

      raw.split(",").map(&:strip).reject(&:blank?)
    end

    def success_flash(total:, off_page:)
      if off_page.positive?
        I18n.t("avo.bulk_update.flash.full_success_with_off_page", count: total, off_page: off_page)
      else
        I18n.t("avo.bulk_update.flash.full_success", count: total)
      end
    end

    def partial_flash(updated:, failed:, total:)
      I18n.t("avo.bulk_update.flash.partial", updated: updated, total: total, failed: failed)
    end

    # ---- error frames ---------------------------------------------------------

    def render_cap_exceeded_frame(total:, max:)
      @banner_variant = :cap_exceeded
      @banner_total = total
      @banner_max = max
      render :error_frame, status: :unprocessable_entity
    end

    def render_no_records_editable_frame(total:)
      @banner_variant = :no_records_editable
      @banner_total = total
      @banner_authorized = 0
      render :error_frame, status: :ok
    end

    def render_n_too_small_frame(authorized:, total:)
      @banner_variant = :n_too_small
      @banner_authorized = authorized
      @banner_total = total
      render :error_frame, status: :unprocessable_entity
    end

    def forbid_unsupported_resource
      render_forbidden(I18n.t("avo.not_authorized"))
    end

    def render_forbidden(message)
      respond_to do |format|
        format.html { head :forbidden }
        format.turbo_stream { head :forbidden }
        format.any { head :forbidden }
      end
    end
  end
end
