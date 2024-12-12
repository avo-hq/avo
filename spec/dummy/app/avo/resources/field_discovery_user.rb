class Avo::Resources::FieldDiscoveryUser < Avo::BaseResource
  self.model_class = ::User
  self.description = 'This is a resource with discovered fields. It will show fields and associations as defined in the model.'
  self.find_record_method = -> {
    query.friendly.find id
  }

  def fields
    main_panel do
      discover_columns except: %i[email active is_admin? birthday is_writer outside_link custom_css]
      discover_associations only: %i[cv_attachment]

      sidebar do
        with_options only_on: :show do
          discover_columns only: %i[email], as: :gravatar, link_to_record: true, as_avatar: :circle
          field :heading, as: :heading, label: ""
          discover_columns only: %i[active], name: "Is active"
        end

        discover_columns only: %i[birthday]

        field :password, as: :password, name: "User Password", required: false, only_on: :forms, help: 'You may verify the password strength <a href="http://www.passwordmeter.com/" target="_blank">here</a>.'
        field :password_confirmation, as: :password, name: "Password confirmation", required: false, revealable: true

        with_options only_on: :forms do
          field :dev, as: :heading, label: '<div class="underline uppercase font-bold">DEV</div>', as_html: true
          discover_columns only: %i[custom_css]
        end
      end
    end

    discover_associations only: %i[posts]
    discover_associations except: %i[posts post cv_attachment]
  end
end
