class Avo::Actions::Sub::DummyAction < Avo::BaseAction
  self.name = -> { "Dummy action#{arguments[:test_action_name]}" }
  self.standalone = true
  # self.turbo = false
  self.visible = -> do
    if resource.is_a? Avo::Resources::User
      view.index?
    else
      true
    end
  end

  def fields
    # field :color, as: :color_pickerrr
    # field :skills, as: :textarea
    # field :name, as: :text
    # field :status,
    #   as: :status,
    #   failed_when: ["closed", :rejected, :failed, "user_reject"],
    #   loading_when: ["loading", :running, :waiting, "Hold On"],
    #   success_when: ["Done"],
    #   nullable: true,
    #   filterable: true,
    #   summarizable: true
    field :country,
      as: :select,
      name: "Country",
      options: Course.countries.map { |country| [country, country] }.prepend(["-", nil]).to_h,
      html: {
        edit: {
          input: {
            data: {
              action: "city-in-country#onCountryChange"
            }
          }
        }
      }
    # field :progress, as: :progress_bar, value_suffix: "%", display_value: true

    # field :password_confirmation, as: :password, name: "Password confirmation", required: false
    # field :price, as: :number
    # field :tiny_description, as: :markdown
    # field :cover_photo, as: :file, is_image: true, as_avatar: :rounded, full_width: true, hide_on: [], accept: "image/*", stacked: true
    # field :files,
    #   as: :files,
    #   translation_key: "avo.field_translations.files",
    #   view_type: :list, stacked: false,
    #   hide_view_type_switcher: false
    # field :service_url, as: :external_image, name: "Image"
    # field :metadata,
    #   as: :code,
    #   format_using: -> {
    #     if view.edit?
    #       JSON.generate(value)
    #     else
    #       value
    #     end
    #   },
    #   update_using: -> do
    #     ActiveSupport::JSON.decode(value)
    #   end
    # field :city_center_area,
    #   as: :area,
    #   geometry: :polygon,
    #   mapkick_options: {
    #     style: "mapbox://styles/mapbox/satellite-v9",
    #     controls: true
    #   },
    #   datapoint_options: {
    #     label: "Paris City Center",
    #     tooltip: "Bonjour mes amis!",
    #     color: "#009099"
    #   }
    field :keep_modal_open, as: :boolean
    field :persistent_text, as: :text
    field :parent_id,
      as: :hidden,
      default: -> do
        # get_id(Avo::App.request.referer) # strip the id from the referer string
        1
      end
    field :parent_type,
      as: :hidden,
      default: -> do
        # get_type(Avo::App.request.referer) # strip the type from the referer string
        "users"
      end
  end

  def handle(**args)
    # Test keep modal open
    if args[:fields][:keep_modal_open]
      succeed "Persistent success response ✌️"
      warn "Persistent warning response ✌️"
      inform "Persistent info response ✌️"
      error "Persistent error response ✌️"
      return keep_modal_open
    end

    if arguments[:special_message]
      succeed "I love 🥑"
    else
      succeed "Success response ✌️"
    end
    warn "Warning response ✌️"
    inform "Info response ✌️"
    error "Error response ✌️"

    # redirect_to "https://www.google.com/"
  end
end
