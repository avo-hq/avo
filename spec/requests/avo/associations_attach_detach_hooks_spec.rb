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

  # Passes the hooks through the field DSL, the way a resource declares them
  def declare_hooks(field_class, field_id, **hooks)
    allow(field_class).to receive(:new).and_wrap_original do |original, id, **args, &block|
      args = args.merge(hooks) if id == field_id
      original.call(id, **args, &block)
    end
  end

  # Each call logs whether the record is attached at that moment, read fresh from the database
  def logging_hooks(field_class, field_id, *names)
    log = calls
    attached = lambda do |parent, record|
      related = parent.class.find(parent.id).send(field_id)
      related.respond_to?(:include?) ? related.include?(record) : related == record
    end
    hooks = names.to_h { |name| [name, -> { log << [name, parent, record, attached.call(parent, record)] }] }
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

  it "runs after_attach for every attached record, with the parent, once the attach is saved" do
    logging_hooks(Avo::Fields::HasManyField, :team_members, :after_attach)

    attach(:team_members, alpha, beta)

    expect(calls).to eq [[:after_attach, team, alpha, true], [:after_attach, team, beta, true]]
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

    expect(calls).to eq [[:before_detach, team, alpha, true], [:after_detach, team, alpha, false]]
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
    expect(flash[:error]).to be_present
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

  it "reports the record a has_one attach replaces as detached" do
    TeamMembership.create!(team: team, user: alpha, level: "admin")
    logging_hooks(Avo::Fields::HasOneField, :admin, :before_detach, :after_detach, :after_attach)

    without_destroy_callback { attach(:admin, beta) }

    expect(team.reload.admin).to eq beta
    expect(calls).to eq [
      [:before_detach, team, alpha, true],
      [:after_detach, team, alpha, false],
      [:after_attach, team, beta, true]
    ]
  end
end
