module Avo
  module Mappings
    unless defined?(ASSOCIATIONS_MAPPING)
      ASSOCIATIONS_MAPPING = {
        ActiveRecord::Reflection::BelongsToReflection => {
          field: "belongs_to"
        },
        ActiveRecord::Reflection::HasOneReflection => {
          field: "has_one"
        },
        ActiveRecord::Reflection::HasManyReflection => {
          field: "has_many"
        },
        ActiveRecord::Reflection::HasAndBelongsToManyReflection => {
          field: "has_and_belongs_to_many"
        }
      }.freeze
    end

    unless defined?(ATTACHMENTS_MAPPING)
      ATTACHMENTS_MAPPING = {
        ActiveRecord::Reflection::HasOneReflection => {
          field: "file"
        },
        ActiveRecord::Reflection::HasManyReflection => {
          field: "files"
        }
      }.freeze
    end

    unless defined?(FIELDS_MAPPING)
      FIELDS_MAPPING = {
        primary_key: {
          field: "id"
        },
        string: {
          field: "text"
        },
        text: {
          field: "textarea"
        },
        integer: {
          field: "number"
        },
        float: {
          field: "number"
        },
        decimal: {
          field: "number"
        },
        datetime: {
          field: "date_time"
        },
        timestamp: {
          field: "date_time"
        },
        time: {
          field: "date_time"
        },
        date: {
          field: "date"
        },
        binary: {
          field: "number"
        },
        boolean: {
          field: "boolean"
        },
        references: {
          field: "belongs_to"
        },
        belongs_to: {
          field: "belongs_to"
        },
        json: {
          field: "code"
        }
      }.freeze
    end

    unless defined?(NAMES_MAPPING)
      NAMES_MAPPING = {
        id: {
          field: "id"
        },
        description: {
          field: "textarea"
        },
        gravatar: {
          field: "gravatar"
        },
        email: {
          field: "text"
        },
        password: {
          field: "password"
        },
        password_confirmation: {
          field: "password"
        },
        stage: {
          field: "select"
        },
        budget: {
          field: "currency"
        },
        money: {
          field: "currency"
        },
        country: {
          field: "country"
        }
      }.freeze
    end
  end
end
