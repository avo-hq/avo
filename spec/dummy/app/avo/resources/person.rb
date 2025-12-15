class Avo::Resources::Person < Avo::BaseResource
  self.title = :name
  self.description = "Demo resource to illustrate Avo's Single Table Inheritance support (Spouse < Person)"
  self.includes = []

  self.link_to_child_resource = true
  self.search = {
    query: -> { query.ransack(id_eq: params[:q], m: "or").result(distinct: false) }
  }

  def fields
    field :name, as: :text, link_to_record: true, sortable: true, stacked: true
    field :type, as: ::Pluggy::Fields::RadioField, name: "Type", options: {Spouse: "Spouse", Sibling: "Sibling"}, include_blank: true, filterable: true
    field :link, as: :text, as_html: true
    field :person, as: :belongs_to
    field :another_person, as: :belongs_to, link_to_child_resource: true
    field :spouses, as: :has_many, hide_search_input: true
    field :relatives,
      as: :has_many,
      hide_search_input: true,
      link_to_child_resource: true,
      description: "People resources is using single table inheritance, we demonstrate the usage of link_to_child_resource.</br> If enabled like in this case, child resources will be used instead of parent resources"
    field :peoples,
      as: :has_many,
      hide_search_input: true,
      description: "Default behaviour with link_to_child_resource disabled"

    tabs do
      tab "Employment" do
        panel do
          card title: "Software Engineer" do
            cluster do
              field :company, stacked: true do
                "TechCorp Inc."
              end
              field :department, stacked: true do
                "Research & Development"
              end
            end

            field :years_of_experience do
              "7 Years"
            end
          end

          sidebar do
            card title: "Employee info" do
              field :employee_id do
                "EMP123456"
              end
              field :supervisor do
                "Jane Smith"
              end
            end
          end
        end
      end

      tab "Address", lazy_load: true do
        panel(title: "Address") do
          row divider: true do
            field :street_address, stacked: true do
              "1234 Elm Street"
            end
            field :city, stacked: true do
              "Los Angeles"
            end
          end

          field :state do
            "California"
          end

          sidebar do
            card do
              field :phone_number do
                "+1 (555) 123-4567"
              end
              field :zip_code do
                "90001"
              end
            end
          end
        end
      end

      tab "Preferences" do
        panel do
          field :preferred_language do
            "English"
          end

          field :theme_mode do
            "Dark Mode"
          end

          field :notification_preference do
            "Email & SMS"
          end

          sidebar do
            card do
              field :timezone do
                "Pacific Time (PST)"
              end
            end
          end
        end
      end
    end
  end
end
