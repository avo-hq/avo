require "rails_helper"

RSpec.describe "BooleanGroupField", type: :system do
  context "database backed BooleanGroupField" do
    describe "with regular input" do
      let!(:user) { create :user, roles: {} }

      context "index" do
        it "displays the users name" do
          visit "/admin/resources/users"

          expect(page).to have_text "ROLES"
          expect(page).to have_text "View"
          find("tr[data-resource-id='#{user.to_param}'] [data-field-id='roles']").find("a", text: "View").hover
          sleep 0.1
          wait_for_loaded

          assert_popup_texts %w(Administrator Manager Writer)
        end
      end

      context "show" do
        it "displays the users roles" do
          visit "/admin/resources/users/#{user.id}"

          show_popup_for("roles")
          sleep 0.1

          assert_popup_texts %w(ROLES Administrator Manager Writer)
          assert_svg_classes %w(text-red-500 text-red-500 text-red-500)
        end
      end

      context "edit" do
        it "changes the users roles" do
          visit "/admin/resources/users/#{user.id}/edit"

          expect(page).to_not have_checked_field "user_roles_administrator"
          expect(page).to_not have_checked_field "user_roles_manager"
          expect(page).to_not have_checked_field "user_roles_writer"

          check "user_roles_admin"
          uncheck "user_roles_manager"
          uncheck "user_roles_writer"

          save

          user_id = page.find('[data-field-id="id"] [data-slot="value"]').text
          user_slug = User.find(user_id).slug
          expect(current_path).to eql "/admin/resources/users/#{user_slug}"

          visit "/admin/resources/users/#{user_slug}"
          show_popup_for("roles")
          sleep 0.1

          assert_popup_texts %w(ROLES Administrator Manager Writer)
          assert_svg_classes %w(text-green-600 text-red-500 text-red-500)
        end

        it "doesn't affect unspecified options" do
          user.update(roles: user.roles.merge({ publisher: true }))

          visit "/admin/resources/users/#{user.id}/edit"

          uncheck "user_roles_admin"
          uncheck "user_roles_manager"
          uncheck "user_roles_writer"

          save

          user.reload
          expect(user.roles).to eql({ admin: false, manager: false, publisher: true,
                                      writer: false }.with_indifferent_access)
        end
      end
    end
  end

  context "non database backed BooleanGroupField" do
    let!(:user) { create :user }

    context "index" do
      it "displays the users permissions" do
        visit "/admin/resources/users"

        expect(page).to have_text "PERMISSIONS"
        expect(page).to have_text "View"
        find("tr[data-resource-id='#{user.to_param}'] [data-field-id='permissions']").find("a", text: "View").hover
        sleep 0.1
        wait_for_loaded

        assert_popup_texts %w[PERMISSIONS Create Read Update Delete]
      end
    end

    context "show" do
      it "displays the users permissions" do
        visit "/admin/resources/users/#{user.id}"

        show_popup_for('permissions')
        sleep 0.1

        assert_popup_texts %w[PERMISSIONS Create Read Update Delete]
        assert_svg_classes %w[text-green-600 text-green-600 text-red-500 text-green-600]
      end
    end

    context "edit" do
      it "does not change the user permissions" do
        visit "/admin/resources/users/#{user.id}/edit"

        expect(page).to have_checked_field "user_permissions_create"
        expect(page).to have_checked_field "user_permissions_read"
        expect(page).to_not have_checked_field "user_permissions_update"
        expect(page).to have_checked_field "user_permissions_delete"

        uncheck "user_permissions_create"
        check   "user_permissions_update"

        save

        user_id = page.find('[data-field-id="id"] [data-slot="value"]').text
        user_slug = User.find(user_id).slug
        expect(current_path).to eql "/admin/resources/users/#{user_slug}"

        visit "/admin/resources/users/#{user_slug}"
        show_popup_for("permissions")
        sleep 0.1

        assert_popup_texts %w[PERMISSIONS Create Read Update Delete]
        assert_svg_classes %w[text-green-600 text-green-600 text-red-500 text-green-600]
      end
    end
  end
end

def show_popup_for(group)
  find("[data-field-id=#{group}]").find("a", text: "View").hover
end

def assert_popup_texts(texts)
  texts.each do |text|
    expect(page).to have_text text
  end
end

def assert_svg_classes(classes)
  classes.each_with_index do |klass, index|
    expect(page.all(".tippy-content svg")[index][:class]).to have_text klass
  end
end
