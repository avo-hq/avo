class Avo::Resources::FieldDiscoveryUser < Avo::BaseResource
  self.model_class = ::User
  self.description = "This is a resource with discovered fields. It will show fields and associations as defined in the model."

  def fields
    main_panel do
      discover_columns except: %i[email active is_admin? birthday is_writer outside_link custom_css]
      discover_associations only: %i[cv_attachment]

      # sidebar do
        discover_columns only: %i[email], as: :gravatar, link_to_record: true, only_on: :show
        field :heading, as: :heading, label: "", only_on: :show
        discover_columns only: %i[active], name: "Is active", only_on: :show

        discover_columns only: %i[birthday]

        field :password, as: :password, name: "User Password", required: false, only_on: :forms, help: 'You may verify the password strength <a href="http://www.passwordmeter.com/" target="_blank">here</a>.'
        field :password_confirmation, as: :password, name: "Password confirmation", required: false, revealable: true

        field :dev, as: :heading, label: '<div class="underline uppercase font-bold">DEV</div>', as_html: true, only_on: :forms
        discover_columns only: %i[custom_css], only_on: :forms
      # end
    end

    discover_associations only: %i[posts]
    discover_associations except: %i[posts post cv_attachment]
  end
end
