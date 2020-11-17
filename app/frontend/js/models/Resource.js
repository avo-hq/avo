import Field from './Field'

export default class Resource {
  static parseResources(resources) {
    return resources.map((resource) => new Resource(resource))
  }

  constructor(resource) {
    this.authorization = resource.authorization
    this.fields = Field.parseFields(resource.fields)
    this.gridFields = resource.grid_fields
    this.id = resource.id
    this.panels = resource.panels
    this.path = resource.path
    this.singularName = resource.singular_name
    this.pluralName = resource.plural_name
    this.title = resource.title
    this.translationKey = resource.translation_key
  }
}
