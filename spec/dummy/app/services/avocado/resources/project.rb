module Avocado
  module Resources
    class Project < Resource
      def initialize
        @title = :name
        @search = [:name, :id]
        @includes = :users
      end

      fields do
        id
        text :name, required: true
        status :status, failed_when: [:closed, :rejected, :failed], loading_when: [:loading, :running, :waiting]
        badge :stage, map: { info: [:discovery, :ideea], success: :done, warning: 'on hold', danger: :cancelled }
        currency :budget, currency: 'EUR', locale: 'de-DE'
        country :country
        number :users_required
        datetime :started_at, time_24hr: true
        files :files
        key_value :meta, key_label: 'Meta key', value_label: 'Meta value', action_text: 'New item', delete_text: 'Remove item', disable_editing_keys: false, disable_adding_rows: false, disable_deleting_rows: false

        has_and_belongs_to_many :users
      end
    end
  end
end
