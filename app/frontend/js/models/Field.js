export default class Field {
  static parseFields(fields) {
    return fields.map((field) => new Field(field))
  }

  constructor(args) {
    Object.assign(this, args)

    this.id = args.id
    this.computed = args.computed
    this.name = args.name
    this.singularName = args.singular_name
    this.pluralName = args.plural_name
    this.block = args.block
    this.component = args.component
    this.required = args.required
    this.readonly = args.readonly
    this.updatable = args.updatable
    this.sortable = args.sortable
    this.nullable = args.nullable
    this.nullValues = args.null_values
    this.computable = args.computable
    this.isArrayParam = args.is_array_param
    this.formatUsing = args.format_using
    this.placeholder = args.placeholder
    this.help = args.help
    this.default = args.default
    this.value = args.value
    this.linkToResource = args.link_to_resource
    this.panelName = args.panel_name
    this.showOnShow = args.show_on_show
  }
}
