require "rails_helper"

# Unit 5a covers ONLY the show path. The handle action ships in Unit 5b.
RSpec.describe "Avo::BulkUpdateController#show", type: :request do
  let(:admin_user) { create :user, roles: {admin: true} }
  let(:other_user) { create :user, roles: {admin: true} }
  let(:resource_class) { Avo::Resources::Project }

  before do
    login_as admin_user
  end

  # The Avo OSS authorization shim always allows. For the K-of-N filtering
  # tests we stub `authorize_action` to allow/deny per record.
  def stub_authorization_per_record(allowed_ids:)
    allow_any_instance_of(Avo::Services::AuthorizationService)
      .to receive(:authorize_action) do |service, _action, **|
        record = service.record
        allowed_ids.include?(record.id)
      end
  end

  describe "happy path" do
    it "renders the slide-out with banner 'Updating N of N' for fully-authorized selection" do
      projects = create_list(:project, 5)
      ids = projects.map(&:id).join(",")

      get "/admin/resources/projects/bulk_update",
        params: {fields: {avo_resource_ids: ids}}

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("turbo-frame")
      expect(response.body).to include("slide_over_frame")
      # K == N banner
      expect(response.body).to include(">5<")
      expect(response.body).not_to match(/were excluded/)
    end

    it "renders the field stack derived from bulk_updatable_field_ids" do
      projects = create_list(:project, 3)
      ids = projects.map(&:id).join(",")

      get "/admin/resources/projects/bulk_update",
        params: {fields: {avo_resource_ids: ids}}

      expect(response).to have_http_status(:ok)
      # Project allowlists :name, :status, :stage, :country, :users_required, :started_at, :description.
      # We confirm at least one of those fields renders an input named under `fields[<key>]`.
      expect(response.body).to match(/name="fields\[(name|status|stage|country|users_required)\]"/)
    end

    it "carries the framework-managed hidden inputs (avo_resource_ids etc.) on the form" do
      projects = create_list(:project, 3)
      ids = projects.map(&:id).join(",")

      get "/admin/resources/projects/bulk_update",
        params: {fields: {avo_resource_ids: ids}}

      expect(response.body).to include('name="fields[avo_resource_ids]"')
      expect(response.body).to include('name="fields[avo_selected_all]"')
      expect(response.body).to include('name="fields[avo_index_query]"')
    end

    it "renders a per-field status notice for each bulk-updatable field" do
      # 3 projects all sharing the same stage value -> all-share notice.
      projects = create_list(:project, 3)
      projects.each { |p| p.update!(stage: "Done", name: "shared name") }
      ids = projects.map(&:id).join(",")

      get "/admin/resources/projects/bulk_update",
        params: {fields: {avo_resource_ids: ids}}

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("bulk-update-status-notice")
    end
  end

  describe "K-of-N authorization filter" do
    it "renders banner 'Updating 3 of 5. 2 records were excluded' when 2 of 5 unauthorized" do
      projects = create_list(:project, 5)
      allowed = projects.first(3)
      stub_authorization_per_record(allowed_ids: allowed.map(&:id))

      ids = projects.map(&:id).join(",")

      get "/admin/resources/projects/bulk_update",
        params: {fields: {avo_resource_ids: ids}}

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(">3<")
      expect(response.body).to include(">5<")
      expect(response.body).to match(/2 records were excluded/)
    end
  end

  describe "edge: 0 of N authorized" do
    it "renders the 'no records editable' frame" do
      projects = create_list(:project, 5)
      stub_authorization_per_record(allowed_ids: [])

      ids = projects.map(&:id).join(",")

      get "/admin/resources/projects/bulk_update",
        params: {fields: {avo_resource_ids: ids}}

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("No selected records are editable by you")
      # The form is NOT rendered.
      expect(response.body).not_to include('name="fields[avo_resource_ids]"')
    end
  end

  describe "edge: K < 2 (N-too-small)" do
    it "renders the N-too-small frame when only 1 of 5 is authorized" do
      projects = create_list(:project, 5)
      stub_authorization_per_record(allowed_ids: [projects.first.id])

      ids = projects.map(&:id).join(",")

      get "/admin/resources/projects/bulk_update",
        params: {fields: {avo_resource_ids: ids}}

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body).to include("at least two records")
      expect(response.body).not_to include('name="fields[avo_resource_ids]"')
    end
  end

  describe "edge: cap exceeded" do
    it "renders the cap-exceeded frame when the count would exceed bulk_update_max_records" do
      # Avoid creating 600 records; instead, lower the cap so 3 records exceed it.
      allow_any_instance_of(resource_class)
        .to receive(:bulk_update_max_records).and_return(2)

      projects = create_list(:project, 3)
      ids = projects.map(&:id).join(",")

      get "/admin/resources/projects/bulk_update",
        params: {fields: {avo_resource_ids: ids}}

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body).to include("Too many records selected")
      expect(response.body).to include("2") # the cap
    end
  end

  describe "edge: bulk_update disabled on resource" do
    it "returns 403 when bulk_update_enabled? is false" do
      projects = create_list(:project, 3)
      ids = projects.map(&:id).join(",")
      allow_any_instance_of(resource_class).to receive(:bulk_update_enabled?).and_return(false)

      get "/admin/resources/projects/bulk_update",
        params: {fields: {avo_resource_ids: ids}}

      expect(response).to have_http_status(:forbidden)
    end
  end

  describe "encrypted query actor binding" do
    let(:projects) { create_list(:project, 3) }
    let(:query) { ::Project.where(id: projects.map(&:id)) }

    def encrypted_payload_for(actor_id, query_relation)
      Avo::Services::EncryptionService.encrypt(
        message: {query: query_relation, actor_id: actor_id},
        purpose: :bulk_update_select_all,
        serializer: Marshal
      )
    end

    it "decrypts and renders the slide-out when the actor_id matches current_user" do
      ciphertext = encrypted_payload_for(admin_user.id, query)

      get "/admin/resources/projects/bulk_update",
        params: {fields: {avo_selected_all: "true", avo_index_query: ciphertext}}

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("slide_over_frame")
    end

    it "returns 403 when actor_id does not match current_user (cross-user replay)" do
      ciphertext = encrypted_payload_for(other_user.id, query)

      get "/admin/resources/projects/bulk_update",
        params: {fields: {avo_selected_all: "true", avo_index_query: ciphertext}}

      expect(response).to have_http_status(:forbidden)
    end

    it "rejects a query encrypted with the Actions ':select_all' purpose (cross-feature replay)" do
      # Encrypted under the Actions purpose - decrypt MUST fail under our distinct purpose.
      foreign_ciphertext = Avo::Services::EncryptionService.encrypt(
        message: {query: query, actor_id: admin_user.id},
        purpose: :select_all,
        serializer: Marshal
      )

      get "/admin/resources/projects/bulk_update",
        params: {fields: {avo_selected_all: "true", avo_index_query: foreign_ciphertext}}

      expect(response).to have_http_status(:forbidden)
    end
  end
end

# Unit 5b: the POST handle action.
RSpec.describe "Avo::BulkUpdateController#handle", type: :request do
  let(:admin_user) { create :user, roles: {admin: true} }
  let(:resource_class) { Avo::Resources::Project }

  before do
    login_as admin_user
  end

  def stub_authorization_per_record(allowed_ids:)
    allow_any_instance_of(Avo::Services::AuthorizationService)
      .to receive(:authorize_action) do |service, _action, **|
        record = service.record
        allowed_ids.include?(record.id)
      end
  end

  def post_handle(ids:, fields: {}, extra: {})
    post "/admin/resources/projects/bulk_update",
      params: {
        fields: {avo_resource_ids: Array(ids).join(",")}.merge(fields),
        **extra
      },
      headers: {"Accept" => "text/vnd.turbo-stream.html"}
  end

  describe "happy path" do
    it "writes the allowlisted attribute on every authorized record" do
      projects = create_list(:project, 3, name: "before")

      post_handle(ids: projects.map(&:id), fields: {name: "after"})

      expect(response).to have_http_status(:ok)
      projects.each { |p| expect(p.reload.name).to eq("after") }
    end

    it "responds with a turbo_stream that closes the slide-out + per-row replace + flash" do
      projects = create_list(:project, 3, name: "before")
      ids_csv = projects.map(&:id).join(",")

      post_handle(
        ids: projects.map(&:id),
        fields: {name: "after"},
        extra: {current_page_ids: ids_csv}
      )

      expect(response.body).to include("turbo-stream")
      expect(response.body).to include("slide_over_frame")
      # Per-row replace for every visible updated id.
      projects.each do |p|
        expect(response.body).to include("projects_#{p.id}_row")
      end
    end
  end

  describe "allowlist filter" do
    it "drops non-allowlisted attribute keys silently" do
      projects = create_list(:project, 2, name: "before")
      before_user_id = projects.first.user_id

      # `:user` (belongs_to) is NOT in the Project resource's bulk_update[:fields] allowlist.
      post_handle(
        ids: projects.map(&:id),
        fields: {name: "after", user_id: 999_999_999}
      )

      expect(response).to have_http_status(:ok)
      projects.each do |p|
        p.reload
        expect(p.name).to eq("after")
        expect(p.user_id).to eq(before_user_id)
      end
    end

    it "drops non-allowlisted keys from the audit event's attempted_keys" do
      projects = create_list(:project, 2)
      captured = nil
      ActiveSupport::Notifications.subscribed(
        ->(_n, _s, _f, _id, payload) { captured = payload },
        "avo.bulk_update.submit"
      ) do
        post_handle(
          ids: projects.map(&:id),
          fields: {name: "after", user_id: 1, role: "admin"}
        )
      end

      expect(captured).not_to be_nil
      expect(captured[:attempted_keys]).to include(:name)
      expect(captured[:attempted_keys]).not_to include(:user_id)
      expect(captured[:attempted_keys]).not_to include(:role)
    end
  end

  describe "blank-skip floor" do
    it "drops blank string values before fill_record (defense against bulk-clearing)" do
      projects = create_list(:project, 2, name: "before")

      post_handle(ids: projects.map(&:id), fields: {name: ""})

      expect(response).to have_http_status(:ok)
      projects.each { |p| expect(p.reload.name).to eq("before") }
    end

    it "drops a blank date value (defense against AR '' -> nil type-cast)" do
      projects = create_list(:project, 2)
      projects.each { |p| p.update!(started_at: Time.zone.parse("2024-01-01")) }

      post_handle(ids: projects.map(&:id), fields: {started_at: ""})

      expect(response).to have_http_status(:ok)
      projects.each { |p| expect(p.reload.started_at).not_to be_nil }
    end
  end

  describe "boolean tri-state sentinel" do
    it "drops the Unchanged sentinel before fill_record" do
      # No boolean field exists on Project, but the filter logic is symmetrical: the
      # sentinel string is dropped if it ever lands as a value on any allowlisted key.
      projects = create_list(:project, 2, name: "before")

      post_handle(
        ids: projects.map(&:id),
        fields: {name: Avo::Fields::BooleanField::EditComponent::BULK_EDIT_UNCHANGED}
      )

      projects.each do |p|
        # `name` was set to "unchanged"-sentinel; controller must drop it.
        p.reload
        expect(p.name).to eq("before")
      end
    end
  end

  describe "authz drift" do
    it "records `:unauthorized_at_write` for records that lose update? between open and submit" do
      projects = create_list(:project, 3, name: "before")
      allowed = projects.first(2)

      # Allow at the open-time filter, then deny per-record at write time.
      open_pass = projects.map(&:id)
      write_pass = allowed.map(&:id)
      call_count = 0
      allow_any_instance_of(Avo::Services::AuthorizationService)
        .to receive(:authorize_action) do |service, _action, **|
          # First N invocations are the open-time filter; subsequent ones are
          # the write-time re-check. The simplest pin is to allow open and
          # deny per-record for the third project.
          record = service.record
          call_count += 1
          if call_count <= projects.size
            open_pass.include?(record.id)
          else
            write_pass.include?(record.id)
          end
        end

      captured = nil
      ActiveSupport::Notifications.subscribed(
        ->(_n, _s, _f, _id, payload) { captured = payload },
        "avo.bulk_update.submit"
      ) do
        post_handle(ids: projects.map(&:id), fields: {name: "after"})
      end

      expect(response).to have_http_status(:ok)
      reasons = captured[:failed].map { |f| f[:reason] }
      expect(reasons).to include(:unauthorized_at_write)
    end
  end

  describe "validation failure" do
    it "captures :validation reason with message; partial-failure response replaces the slide-out body" do
      projects = create_list(:project, 3, name: "before")

      # Make one record fail validation via a stubbed save!.
      bad_id = projects.last.id
      allow_any_instance_of(::Project).to receive(:save!).and_wrap_original do |orig, *args|
        if orig.receiver.id == bad_id
          orig.receiver.errors.add(:name, "is reserved")
          raise ActiveRecord::RecordInvalid.new(orig.receiver)
        else
          orig.call(*args)
        end
      end

      post_handle(ids: projects.map(&:id), fields: {name: "after"})

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("bulk-update-failure-list")
      # The other two records still landed.
      expect(projects.first.reload.name).to eq("after")
      expect(projects.last.reload.name).to eq("before")
    end
  end

  describe "concurrent modification" do
    it "captures :concurrent_modification reason on StaleObjectError" do
      projects = create_list(:project, 2, name: "before")
      bad_id = projects.last.id

      allow_any_instance_of(::Project).to receive(:save!).and_wrap_original do |orig, *args|
        if orig.receiver.id == bad_id
          raise ActiveRecord::StaleObjectError.new(orig.receiver, "update")
        else
          orig.call(*args)
        end
      end

      captured = nil
      ActiveSupport::Notifications.subscribed(
        ->(_n, _s, _f, _id, payload) { captured = payload },
        "avo.bulk_update.submit"
      ) do
        post_handle(ids: projects.map(&:id), fields: {name: "after"})
      end

      reasons = captured[:failed].map { |f| f[:reason] }
      expect(reasons).to include(:concurrent_modification)
    end
  end

  describe "audit event payload" do
    it "fires `avo.bulk_update.submit` with actor/resource/updated/failed/keys" do
      projects = create_list(:project, 2, name: "before")
      captured = nil

      ActiveSupport::Notifications.subscribed(
        ->(_n, _s, _f, _id, payload) { captured = payload },
        "avo.bulk_update.submit"
      ) do
        post_handle(ids: projects.map(&:id), fields: {name: "after"})
      end

      expect(captured[:actor_id]).to eq(admin_user.id)
      expect(captured[:resource]).to eq("Avo::Resources::Project")
      expect(captured[:updated_ids]).to match_array(projects.map(&:id))
      expect(captured[:failed]).to eq([])
      expect(captured[:attempted_keys]).to eq([:name])
    end

    it "strips :message from failed entries (PII safety, keys-only invariant)" do
      projects = create_list(:project, 2, name: "before")
      bad_id = projects.last.id

      allow_any_instance_of(::Project).to receive(:save!).and_wrap_original do |orig, *args|
        if orig.receiver.id == bad_id
          orig.receiver.errors.add(:name, "is reserved")
          raise ActiveRecord::RecordInvalid.new(orig.receiver)
        else
          orig.call(*args)
        end
      end

      captured = nil
      ActiveSupport::Notifications.subscribed(
        ->(_n, _s, _f, _id, payload) { captured = payload },
        "avo.bulk_update.submit"
      ) do
        post_handle(ids: projects.map(&:id), fields: {name: "after"})
      end

      failed_entry = captured[:failed].first
      expect(failed_entry.keys).to contain_exactly(:id, :reason)
      expect(failed_entry).not_to have_key(:message)
    end

    it "fires the event even on empty submission (no allowlisted keys), with empty arrays" do
      projects = create_list(:project, 2)
      captured = nil

      ActiveSupport::Notifications.subscribed(
        ->(_n, _s, _f, _id, payload) { captured = payload },
        "avo.bulk_update.submit"
      ) do
        post_handle(ids: projects.map(&:id), fields: {})
      end

      expect(captured).not_to be_nil
      expect(captured[:updated_ids]).to eq([])
      expect(captured[:attempted_keys]).to eq([])
    end
  end

  # NOTE on override lambda shape: `Avo::ExecutionContext#handle` calls
  # `instance_exec(&target)` which does NOT pass kwargs into the lambda.
  # Override authors access the caller's `records`, `attributes`, and
  # `current_user` via accessor methods on the ExecutionContext instance
  # (set by the framework before instance_exec runs). Lambdas in tests must
  # therefore take ZERO args and reference the accessors directly.
  describe "handle_bulk_update override" do
    around do |example|
      original = resource_class.bulk_update
      resource_class.bulk_update = original.merge(
        handle_bulk_update: -> {
          {updated_ids: records.map(&:id), failed: []}
        }
      )
      example.run
      resource_class.bulk_update = original
    end

    it "invokes the override and uses its return values for the audit payload" do
      projects = create_list(:project, 3, name: "before")
      captured = nil

      ActiveSupport::Notifications.subscribed(
        ->(_n, _s, _f, _id, payload) { captured = payload },
        "avo.bulk_update.submit"
      ) do
        post_handle(ids: projects.map(&:id), fields: {name: "after"})
      end

      expect(response).to have_http_status(:ok)
      expect(captured[:updated_ids]).to match_array(projects.map(&:id))
      expect(captured[:failed]).to eq([])
    end

    it "passes only authz-re-checked records to the override" do
      projects = create_list(:project, 3, name: "before")

      # Deny one record per-record at write time. The framework should NOT pass
      # it to the override.
      denied = projects.last.id
      allow_any_instance_of(Avo::Services::AuthorizationService)
        .to receive(:authorize_action) do |service, _action, **|
          service.record.id != denied
        end

      # The override pushes IDs into `seen` via a closure so the spec can
      # inspect what records the framework yielded to it.
      seen = []
      resource_class.bulk_update = resource_class.bulk_update.merge(
        handle_bulk_update: -> {
          records.each { |r| seen << r.id }
          {updated_ids: records.map(&:id), failed: []}
        }
      )

      post_handle(ids: projects.map(&:id), fields: {name: "after"})

      expect(seen).not_to include(denied)
      expect(seen).to match_array(projects.first(2).map(&:id))
    end
  end

  describe "handle_bulk_update override return-shape validation" do
    around do |example|
      original = resource_class.bulk_update
      example.run
      resource_class.bulk_update = original
    end

    it "raises ArgumentError when override returns a Hash missing :updated_ids" do
      resource_class.bulk_update = resource_class.bulk_update.merge(
        handle_bulk_update: -> {
          {failed: []}
        }
      )

      projects = create_list(:project, 2)

      captured = nil
      ActiveSupport::Notifications.subscribed(
        ->(_n, _s, _f, _id, payload) { captured = payload },
        "avo.bulk_update.submit"
      ) do
        expect {
          post_handle(ids: projects.map(&:id), fields: {name: "after"})
        }.to raise_error(ArgumentError, /updated_ids/)
      end

      # No audit event fires on a misconfigured override.
      expect(captured).to be_nil
    end

    it "raises ArgumentError when override returns a non-Hash" do
      resource_class.bulk_update = resource_class.bulk_update.merge(
        handle_bulk_update: -> {
          "not a hash"
        }
      )

      projects = create_list(:project, 2)

      expect {
        post_handle(ids: projects.map(&:id), fields: {name: "after"})
      }.to raise_error(ArgumentError)
    end
  end

  describe "per-row Turbo Stream cap" do
    it "emits replaces only for current_page_ids intersection; flash names off-page count" do
      projects = create_list(:project, 3, name: "before")

      visible = projects.first(2).map(&:id).join(",")
      post_handle(
        ids: projects.map(&:id),
        fields: {name: "after"},
        extra: {current_page_ids: visible}
      )

      # The non-visible record's row replace MUST NOT appear in the body.
      hidden_id = projects.last.id
      expect(response.body).not_to include("projects_#{hidden_id}_row")

      # The visible IDs should be present.
      projects.first(2).each do |p|
        expect(response.body).to include("projects_#{p.id}_row")
      end
    end
  end
end
