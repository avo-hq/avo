module Avo::Fields
  # COMMON_OPTIONS = [:name, :translation_key, :required, :readonly, :disabled, :sortable, :summarizable, :nullable, :format_using, :update_using, :decorate, :placeholder, :autocomplete, :help, :default, :visible, :as_avatar, :html, :stacked, :components, :for_attribute, :meta, :copyable]

  FRAME_BASE_OPTIONS = {
    use_resource: {
      default: nil,
    },
    reloadable: {
      default: nil,
    },
    linkable: {
      default: nil,
    },
    description: {
      default: nil,
    },
  }


  COMMON_OPTIONS = {
    name: {
      default: nil
    },
    translation_key: {
      default: nil
    },
    required: {
      default: :nil,
      description: "The required field yada yada yada"
    },
    readonly: {
      default: false
    },
    disabled: {
      default: false
    },
    sortable: {
      default: false
    },
    summarizable: {
      default: false
    },
    nullable: {
      default: false
    },
    null_values: {
      default: [nil, ""]
    },
    format_using: {
      default: nil,
    },
    update_using: {
      default: nil,
    },
    decorate: {
      default: nil,
    },
    placeholder: {
      default: nil,
    },
    autocomplete: {
      default: nil,
    },
    help: {
      default: nil,
    },
    default: {
      default: nil,
    },
    visible: {
      default: nil,
    },
    as_avatar: {
      default: false
    },
    html: {
      default: nil,
    },
    stacked: {
      default: nil,
    },
    as_avatar: {
      default: false
    },
    components: {
      default: {}
    },
    for_attribute: {
      default: nil
    },
    meta: {
      default: nil
    },
    copyable: {
      default: false
    },
    # ## END FROM BASE FIELD
    # ## START TEXT FIELD
    # link_to_record: {
    #   default: nil
    # },
    # as_html: {
    #   default: nil
    # },
    # protocol: {
    #   default: nil,
    #   description: "Protocol field description!"
    # },
    # ## END TEXT FIELD
    # ## START TEXTAREA FIELD
    # rows: {
    #   default: 5,
    #   description: "Something"
    # }
    ## END TEXTAREA FIELD
    # readonly: {
    #   possible_values: [true, false],
    #   default_value: false,
    #   type: :boolean,
    #   description: "This option...",
    #   execution_context: true,
    #   execution_context_variables: [:record, :resource],
    # },
    # disabled: {
    #   possible_values: [true, false],
    #   default_value: false,
    #   type: :boolean,
    #   description: "This option...",
    #   execution_context: true,
    #   execution_context_variables: [:record, :resource],
    # },
  }
end

# 1 - Can be overridden (Avo::Fields::OPTIONS[:readonly][:default_value] = true)
# 2 - On each field when specified "supports :readonly" all the context is fetched from here
# 3 - will create the getter like:

# def readonly
#   Avo::ExecutionContext.new(target: @readonly, **Avo::Fields::OPTIONS[:readonly][:execution_context_variables])
# end

# TODO maybe: when supported is declared each field will register a own hash and that will be used on everithing, this general one is only for commun fields
# Avo::Fields::TextField.supported_options should return a hash like:
# {
#   decorate: { default: nil }...
#   ...
# }
