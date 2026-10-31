# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Association field attach and detach hooks", type: :request do
  include_context "with a destroyable join record"

  let(:admin_user) { create :user, roles: {admin: true} }
  let(:team) { create :team }
  let(:alpha) { create :user }
  let(:beta) { create :user }
  let(:calls) { [] }

  before do
    login_as admin_user, scope: :user
  end

  # Hands the hooks to the field's constructor, where a resource's `field` call puts its options
  def declare_hooks(field_class, field_id, **hooks)
    allow(field_class).to receive(:new).and_wrap_original do |original, id, **args, &block|
      args = args.merge(hooks) if id == field_id
      original.call(id, **args, &block)
    end
  end

  # Each call logs whether the record is attached at that moment, and whether the hook runs inside Avo's
  # transaction: the spec's own transaction is the baseline, so an after hook run before the commit shows up.
  def logging_hooks(field_class, field_id, *names)
    log = calls
    baseline = ActiveRecord::Base.connection.open_transactions
    attached = lambda do |parent, record|
      related = parent.class.find(parent.id).send(field_id)
      related.respond_to?(:include?) ? related.include?(record) : related == record
    end
    hooks = names.to_h do |name|
      [name, -> { log << [name, parent, record, attached.call(parent, record), ActiveRecord::Base.connection.open_transactions > baseline] }]
    end
    declare_hooks(field_class, field_id, **hooks)
  end

  def attach(association, *records)
    post "/admin/resources/teams/#{team.id}/#{association}",
      params: {fields: {related_id: records.map(&:id)}, view: "show"},
      as: :turbo_stream
  end

  def detach(association, record)
    without_destroy_callback { delete "/admin/resources/teams/#{team.id}/#{association}/#{record.id}", as: :turbo_stream }
  end

  it "runs before_attach inside the transaction and after_attach once the attach is saved, for every record" do
    logging_hooks(Avo::Fields::HasManyField, :team_members, :before_attach, :after_attach)

    attach(:team_members, alpha, beta)

    expect(calls).to eq [
      [:before_attach, team, alpha, false, true],
      [:before_attach, team, beta, false, true],
      [:after_attach, team, alpha, true, false],
      [:after_attach, team, beta, true, false]
    ]
  end

  it "fails a has_many attach whose record is invalid, without running after_attach" do
    invalid_post = create :post
    invalid_post.update_column :name, ""
    log = calls
    declare_hooks Avo::Fields::HasManyField, :posts, after_attach: -> { log << record }

    post "/admin/resources/users/#{alpha.to_param}/posts", params: {fields: {related_id: invalid_post.to_param}, view: "show"}, as: :turbo_stream

    expect(alpha.reload.posts).to be_empty
    expect(calls).to be_empty
    expect(response.body).to include "Validation failed: Name"
  end

  it "refuses a has_one attach with several ids, so the current record can't skip before_detach" do
    TeamMembership.create!(team: team, user: alpha, level: "admin")
    log = calls
    declare_hooks Avo::Fields::HasOneField, :admin,
      before_detach: -> { raise "the admin stays" },
      after_attach: -> { log << record }

    without_destroy_callback { attach(:admin, alpha, beta) }

    expect(team.reload.admin).to eq alpha
    expect(calls).to be_empty
  end

  it "rolls back the whole attach and skips after_attach when before_attach raises" do
    log = calls
    declare_hooks Avo::Fields::HasManyField, :team_members,
      before_attach: -> { raise "not this one" if record == beta },
      after_attach: -> { log << record }

    attach(:team_members, alpha, beta)

    expect(team.reload.team_members).to be_empty
    expect(calls).to be_empty
  end

  it "runs before_detach while the record is attached and after_detach once it is gone" do
    team.team_members << alpha
    logging_hooks(Avo::Fields::HasManyField, :team_members, :before_detach, :after_detach)

    detach(:team_members, alpha)

    expect(calls).to eq [[:before_detach, team, alpha, true, true], [:after_detach, team, alpha, false, false]]
  end

  it "reports a detach that before_detach vetoed with a rollback as failed" do
    team.team_members << alpha
    log = calls
    declare_hooks Avo::Fields::HasManyField, :team_members,
      before_detach: -> { raise ActiveRecord::Rollback },
      after_detach: -> { log << record }

    detach(:team_members, alpha)

    expect(team.reload.team_members).to eq [alpha]
    expect(calls).to be_empty
    expect(response.body).to include I18n.t("avo.failed")
    expect(response.body).not_to include "detached"
  end

  it "reports a rolled back detach as failed on a plain html request too" do
    team.team_members << alpha
    declare_hooks Avo::Fields::HasManyField, :team_members, before_detach: -> { raise ActiveRecord::Rollback }

    without_destroy_callback { delete "/admin/resources/teams/#{team.id}/team_members/#{alpha.id}" }

    expect(team.reload.team_members).to eq [alpha]
    expect(flash[:error]).to eq I18n.t("avo.failed")
    expect(flash[:notice]).to be_nil
  end

  it "runs no detach hooks for a record that isn't attached to the parent" do
    team.team_members << alpha
    logging_hooks(Avo::Fields::HasManyField, :team_members, :before_detach, :after_detach)

    detach(:team_members, beta)

    expect(calls).to be_empty
    expect(team.reload.team_members).to eq [alpha]
  end

  it "runs no detach hooks for a has_many record that belongs to another parent" do
    owner = create :user
    post = create :post, user: owner
    log = calls
    hook = -> { log << record }
    declare_hooks Avo::Fields::HasManyField, :posts, before_detach: hook, after_detach: hook

    without_destroy_callback { delete "/admin/resources/users/#{alpha.to_param}/posts/#{post.to_param}", as: :turbo_stream }

    expect(calls).to be_empty
    expect(post.reload.user).to eq owner
  end

  it "doesn't destroy another parent's record through a dependent: :destroy has_many" do
    reflection = User.reflect_on_association(:posts)
    allow(reflection).to receive(:options).and_return(reflection.options.merge(dependent: :destroy))
    owner = create :user
    post = create :post, user: owner

    delete "/admin/resources/users/#{alpha.to_param}/posts/#{post.to_param}", as: :turbo_stream

    expect(Post.exists?(post.id)).to be true
  end

  it "reports the record a has_one attach replaces as detached" do
    TeamMembership.create!(team: team, user: alpha, level: "admin")
    logging_hooks(Avo::Fields::HasOneField, :admin, :before_detach, :after_detach, :after_attach)

    without_destroy_callback { attach(:admin, beta) }

    expect(team.reload.admin).to eq beta
    expect(calls).to eq [
      [:before_detach, team, alpha, true, true],
      [:after_detach, team, alpha, false, false],
      [:after_attach, team, beta, true, false]
    ]
  end

  it "reports a plain has_one replace as a detach of the old record" do
    old_fish = create :fish, user: alpha
    new_fish = create :fish
    logging_hooks(Avo::Fields::HasOneField, :fish, :before_detach, :after_detach, :after_attach)

    post "/admin/resources/users/#{alpha.to_param}/fish", params: {fields: {related_id: new_fish.id}, view: "show"}, as: :turbo_stream

    expect(alpha.reload.fish).to eq new_fish
    expect(calls).to eq [
      [:before_detach, alpha, old_fish, true, true],
      [:after_detach, alpha, old_fish, false, false],
      [:after_attach, alpha, new_fish, true, false]
    ]
  end

  it "runs no detach hooks when a has_one attach picks the record already attached" do
    TeamMembership.create!(team: team, user: alpha, level: "admin")
    logging_hooks(Avo::Fields::HasOneField, :admin, :before_detach, :after_detach, :after_attach)

    without_destroy_callback { attach(:admin, alpha) }

    expect(calls.map(&:first)).to eq [:after_attach]
  end
end
