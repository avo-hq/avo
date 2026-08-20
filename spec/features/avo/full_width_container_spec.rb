require "rails_helper"

RSpec.feature "ContainerWidth", type: :feature do
  let(:user) { create :user }

  subject do
    visit url
    page.body
  end

  describe "default (no container_width set)" do
    context "index" do
      let(:url) { "/admin/resources/users" }
      it { is_expected.to include "container-lg" }
    end

    context "show" do
      let(:url) { "/admin/resources/users/#{user.slug}" }
      it { is_expected.to include "container-md" }
    end

    context "edit" do
      let(:url) { "/admin/resources/users/#{user.slug}/edit" }
      it { is_expected.to include "container-md" }
    end
  end

  describe "symbol :full — applies to all views" do
    before { Avo.configuration.container_width = :full }
    after { Avo.configuration.container_width = nil }

    context "index" do
      let(:url) { "/admin/resources/users" }
      it { is_expected.to include "container-full" }
      it { is_expected.not_to include "container-lg" }
    end

    context "show" do
      let(:url) { "/admin/resources/users/#{user.slug}" }
      it { is_expected.to include "container-full" }
    end

    context "edit" do
      let(:url) { "/admin/resources/users/#{user.slug}/edit" }
      it { is_expected.to include "container-full" }
    end
  end

  describe "hash { index: :full } — only index is full" do
    before { Avo.configuration.container_width = {index: :full} }
    after { Avo.configuration.container_width = nil }

    context "index" do
      let(:url) { "/admin/resources/users" }
      it { is_expected.to include "container-full" }
      it { is_expected.not_to include "container-lg" }
    end

    context "show" do
      let(:url) { "/admin/resources/users/#{user.slug}" }
      it { is_expected.to include "container-md" }
      it { is_expected.not_to include "container-full" }
    end
  end

  describe "group alias { single: :full } — everything but index is full" do
    before { Avo.configuration.container_width = {single: :full} }
    after { Avo.configuration.container_width = nil }

    context "index" do
      let(:url) { "/admin/resources/users" }
      it { is_expected.to include "container-lg" }
      it { is_expected.not_to include "container-full" }
    end

    context "show" do
      let(:url) { "/admin/resources/users/#{user.slug}" }
      it { is_expected.to include "container-full" }
    end
  end
end
