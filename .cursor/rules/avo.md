---
description:
globs:
alwaysApply: true
---
# Avo

Lean teams use Avo to build exceptional internal tools while it handles the technical heavy lifting, so they can focus on what matters.

Avo offers a few big features to get that done:

- CRUD
- Dashboards
- Advanced filters
- Kanban boards
- Collaboration tools
- Audit logging

CRUD is probably the most important feature of Avo. It's how you create, read, update and delete records (manage records).

# Resources

The Avo CRUD functionality uses the concept of a resource. A resource belongs to a model and a model may have multiple resources.
The model is how Rails talks to the database and the resource is how Avo talks to Rails and knows how to fetch and manipulate the records.

Each resource is a ruby class in this configuration `Avo::Resources::RESOURCE_NAME` and inherits the `Avo::BaseResource` class which inherits `Avo::Resources::Base`. `Avo::BaseResource` is empty so the user can override anything they want on a global level in theyr own app.

A resource has a multitude of options which are usually declared using the `self.OPTION_NAME = ` format. They can take a simple value like a string, boolean, symbol, hash or array or they can take an `ExecutionContext` which will give the developer much more control over what they can return from it.

## Fields

Fields are declared using the `field` method inside a `fields` method in a resource like so:

```ruby
class Avo::Resources::Team < Avo::BaseResource
  def fields
    field :id, as: :id
    field :name, as: :text
    field :description, as: :textarea
  end
end
```

All fields have a name which is the first argument and the type of the field, as the `as:` argument.

Most fields support optons that are universal for all fields. Some examples are: `readonly`, `disabled`, `help`, `format_using`, `update_using`, `hide_on`, `show_on`, and others.

Some fields have their own proprietary options, like `rows` for `textarea` fields and `options` for `select` fields.

## Actions

Actions are a way to apply custom logic to one or more records. They are declared using the `action` method inside a `actions` method in a resource and they show up in UI in the form of a dropdown list.

```ruby
class Avo::Resources::Team < Avo::BaseResource
  def actions
    action :export
  end
end
```

Users can add them outside the dropdown list by using the custom controls method `self.show_controls` for the show page, `self.edit_controls` for the edit page and `self.index_controls` for the index page.

```ruby
class Avo::Resources::Team < Avo::BaseResource
  self.show_controls = -> {
    action :export
  }
end
```

## Stan Filters

Filters are a way to filter the records that are shown in the index page.

They are declared using the `filter` method inside a `filters` method in a resource like so:


