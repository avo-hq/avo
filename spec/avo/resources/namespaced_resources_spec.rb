require "rails_helper"

# Define real namespaced resource classes so they're available to all examples.
# Using a unique namespace (NamespaceTest) avoids polluting the resource
# manager with conflicting model mappings.
module Avo
  module Resources
    module NamespaceTest
      module Baz
      end
    end
  end
end

class ::Avo::Resources::NamespaceTest::Bar < ::Avo::BaseResource
  self.model_class = "Course::Link"
end

class ::Avo::Resources::NamespaceTest::Baz::Qux < ::Avo::BaseResource
  self.model_class = "Course::Link"
end

RSpec.describe "Namespaced resource conventions" do
  describe "class_name" do
    it "returns the full relative name for non-namespaced resources" do
      expect(::Avo::Resources::User.class_name).to eq "User"
    end

    it "returns the full relative name for namespaced resources" do
      expect(::Avo::Resources::NamespaceTest::Bar.class_name).to eq "NamespaceTest::Bar"
    end

    it "handles deeply nested namespaces" do
      expect(::Avo::Resources::NamespaceTest::Baz::Qux.class_name).to eq "NamespaceTest::Baz::Qux"
    end
  end

  describe "demodulized_class_name" do
    it "returns just the last segment" do
      expect(::Avo::Resources::User.demodulized_class_name).to eq "User"
      expect(::Avo::Resources::NamespaceTest::Bar.demodulized_class_name).to eq "Bar"
      expect(::Avo::Resources::NamespaceTest::Baz::Qux.demodulized_class_name).to eq "Qux"
    end
  end

  describe "route_path" do
    it "returns the slash-separated path with last segment pluralized" do
      expect(::Avo::Resources::User.route_path).to eq "users"
      expect(::Avo::Resources::NamespaceTest::Bar.route_path).to eq "namespace_test/bars"
      expect(::Avo::Resources::NamespaceTest::Baz::Qux.route_path).to eq "namespace_test/baz/quxes"
    end
  end

  describe "route_key" do
    it "returns the underscore-joined identifier" do
      expect(::Avo::Resources::User.route_key).to eq "users"
      expect(::Avo::Resources::NamespaceTest::Bar.route_key).to eq "namespace_test_bars"
      expect(::Avo::Resources::NamespaceTest::Baz::Qux.route_key).to eq "namespace_test_baz_quxes"
    end
  end

  describe "singular_route_key" do
    it "returns the singularized route_key" do
      expect(::Avo::Resources::User.singular_route_key).to eq "user"
      expect(::Avo::Resources::NamespaceTest::Bar.singular_route_key).to eq "namespace_test_bar"
    end
  end

  describe "controller_path" do
    it "returns the slash-separated controller path" do
      expect(::Avo::Resources::User.controller_path).to eq "users"
      expect(::Avo::Resources::NamespaceTest::Bar.controller_path).to eq "namespace_test/bars"
    end
  end

  describe "model_class" do
    it "infers a namespaced model from a namespaced resource without an override" do
      expect(::Avo::Resources::Course::Link.model_class).to eq ::Course::Link
    end

    it "respects self.model_class on a namespaced resource" do
      expect(::Avo::Resources::NamespaceTest::Bar.model_class).to eq ::Course::Link
    end
  end

  describe "translation_key" do
    it "uses the full underscored class name so namespaced resources get distinct keys" do
      expect(::Avo::Resources::User.translation_key).to eq "avo.resource_translations.user"
      expect(::Avo::Resources::NamespaceTest::Bar.translation_key).to eq "avo.resource_translations.namespace_test/bar"
      expect(::Avo::Resources::NamespaceTest::Baz::Qux.translation_key).to eq "avo.resource_translations.namespace_test/baz/qux"
    end

    it "respects an explicit self.translation_key override" do
      expect(::Avo::Resources::User.custom_translation_key).to eq "avo.resource_translations.user"
    end
  end
end
