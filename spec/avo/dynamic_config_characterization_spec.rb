require "rails_helper"

# Characterization spec for the surfaces the dynamic-config provider seams hook
# into (Unit 2). It pins *today's* behavior BEFORE the seams are introduced and
# must stay green after, proving the null provider changes nothing.
#
# These assertions intentionally describe observable behavior (option reads,
# item building, entity bags, configuration getters, class-level query/find
# paths, navigation) rather than internals, so they double as the "no provider
# registered → behavior unchanged" guarantee (R1).
RSpec.describe "Dynamic config seams — characterization (no provider)" do
  describe "instance option reads" do
    it "reads resource options off the class defaults" do
      resource = Avo::Resources::Post.new(view: Avo::ViewInquirer.new("index"))

      expect(resource.title).to eq(:name)
      expect(resource.includes).to include(:user)
      expect(Avo::Resources::User.new.record_selector).to be(true)
    end

    it "carries no per-instance overrides by default" do
      a = Avo::Resources::Post.new(view: Avo::ViewInquirer.new("index"))
      b = Avo::Resources::Post.new(view: Avo::ViewInquirer.new("index"))

      expect(a.title).to eq(b.title)
      expect(a.title).to eq(Avo::Resources::Post.title)
    end
  end

  describe "detect_fields → items_holder" do
    it "builds a fresh per-instance items holder populated with items" do
      resource = Avo::Resources::User.new(view: Avo::ViewInquirer.new("index"))

      returned = resource.detect_fields

      expect(returned).to be(resource)
      expect(resource.items_holder).to be_a(Avo::Resources::Items::Holder)
      expect(resource.items).not_to be_empty
    end

    it "rebuilds the holder on each detect_fields call" do
      resource = Avo::Resources::User.new(view: Avo::ViewInquirer.new("index"))

      resource.detect_fields
      first_holder = resource.items_holder
      resource.detect_fields

      expect(resource.items_holder).not_to be(first_holder)
    end
  end

  describe "entity bags (actions / filters / scopes)" do
    it "returns loader bags as arrays" do
      resource = Avo::Resources::Post.new(view: Avo::ViewInquirer.new("index"))

      expect(resource.get_actions).to be_an(Array)
      expect(resource.get_filters).to be_an(Array)
      expect(resource.get_scopes).to be_an(Array)
    end

    it "populates the actions bag with the file-declared actions" do
      resource = Avo::Resources::City.new(view: Avo::ViewInquirer.new("index"))

      classes = resource.get_actions.map { |entry| entry[:class].to_s }

      expect(classes).to include("Avo::Actions::City::Update")
    end
  end

  describe "Configuration getters" do
    it "reads scalar configuration values" do
      expect(Avo.configuration.app_name).to be_a(String)
      expect(Avo.configuration.per_page).to eq(24)
      expect(Avo.configuration.currency).to eq("USD")
      expect(Avo.configuration.default_view_type).to eq(:table)
    end

    it "returns a memoized appearance object" do
      expect(Avo.configuration.appearance).to be_a(Avo::Configuration::Appearance)
    end
  end

  describe "class-level query / find paths" do
    it "query_scope returns a relation for the model" do
      scope = Avo::Resources::User.query_scope

      expect(scope).to be_a(ActiveRecord::Relation)
      expect(scope.klass).to eq(User)
    end

    it "find_scope returns a queryable relation for the model" do
      expect(Avo::Resources::User.find_scope.all).to be_a(ActiveRecord::Relation)
    end

    it "find_record finds the record by id" do
      user = User.create!(first_name: "Ada", last_name: "Lovelace", email: "ada+char@example.com", password: "password", roles: {admin: true})

      found = Avo::Resources::User.find_record(user.id)

      expect(found).to eq(user)
    ensure
      user&.destroy
    end
  end

  describe "navigation / discovery" do
    it "resources_for_navigation returns visible resources" do
      Avo.init

      navigable = Avo.resource_manager.resources_for_navigation

      expect(navigable).to be_an(Array)
      expect(navigable).to all(satisfy { |resource| resource.visible_on_sidebar })
    end

    it "exposes navigation_label and icon on the class" do
      expect(Avo::Resources::User.navigation_label).to be_a(String)
      expect(Avo::Resources::User).to respond_to(:icon)
    end
  end
end
