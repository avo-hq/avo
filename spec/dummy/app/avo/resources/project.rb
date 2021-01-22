module Avo
  module Resources
    class Project < Resource
      def initialize
        @title = :name
        @search = [:name, :id]
        @includes = :users
      end

      fields do
        id link_to_resource: true
        text :name, required: true
        # status :status, failed_when: [:closed, :rejected, :failed], loading_when: [:loading, :running, :waiting], nullable: true

        # select :stage, options: ::Project.stages, placeholder: 'Choose the stage.', display_with_value: true

        select :stage, options: ::Project.stages, placeholder: 'Choose the stage.', display_with_value: true
        # select :stage, options: { 'Discovery': 'discovery', 'Ideea': 'ideea', 'Done': 'done', 'On hold': 'on hold', 'Cancelled': 'cancelled' }, placeholder: 'Choose the stage.', display_with_value: false

        # badge :stage, options: { info: ['Discovery', 'Ideea'], success: 'Done', warning: 'On hold', danger: 'Cancelled' }
        # currency :budget, currency: 'EUR', locale: 'de-DE'
        # country :country
        # number :users_required
        text :users_required
        # datetime :started_at, name: 'Started', time_24hr: true, relative: true
        markdown :description, height: '350px'
        # files :files, translation_key: 'avo.field_translations.file'
        # key_value :meta, key_label: 'Meta key', value_label: 'Meta value', action_text: 'New item', delete_text: 'Remove item', disable_editing_keys: false, disable_adding_rows: false, disable_deleting_rows: false

        # has_and_belongs_to_many :users
        use_filter Avo::Filters::PeopleFilter
        use_filter Avo::Filters::People2Filter
        # use_filter Avo::Filters::PublishedFilter
        # use_filter Avo::Filters::FeaturedFilter
        # use_filter Avo::Filters::MembersFilter
      end
    end
  end
end
