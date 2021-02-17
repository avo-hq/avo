module Avo
  module Resources
    class Project < Resource
      def configure
        @title = :name
        @search = [:name, :id]
        @includes = :users
      end

      def fields(request)
        f.id link_to_resource: true
        f.text :name, required: true
        # field.text :name, required: true
        # status :status, failed_when: [:closed, :rejected, :failed], loading_when: [:loading, :running, :waiting], nullable: true
        # select :stage, hide_on: [:show, :index], enum: ::Project.stages, placeholder: 'Choose the stage.', display_value: true
        f.badge :stage, options: { info: ['Discovery', 'Ideea'], success: 'Done', warning: 'On hold', danger: 'Cancelled' }
        # currency :budget, currency: 'EUR', locale: 'de-DE'
        # country :country
        f.number :users_required, min: 10, max: 1000000, step: 1
        # text :users_required
        # datetime :started_at, name: 'Started', time_24hr: true, relative: true
        f.markdown :description, height: '350px'
        # files :files, translation_key: 'avo.field_translations.file'
        # key_value :meta, key_label: 'Meta key', value_label: 'Meta value', action_text: 'New item', delete_text: 'Remove item', disable_editing_keys: false, disable_adding_rows: false, disable_deleting_rows: false

        f.has_and_belongs_to_many :users
      end

      def filters(request)
        filter.use Avo::Filters::PeopleFilter
        filter.use Avo::Filters::People2Filter
        filter.use Avo::Filters::FeaturedFilter
        filter.use Avo::Filters::MembersFilter
      end
    end
  end
end
