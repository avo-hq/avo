# Avo - Toolkit for building internal tools with Rails and Hotwire


## Developing components

The `Avo::DiscreetInformationComponent` component was created by hand. Use that as a template for other components.

See the patterns applied in the `rb`, `erb` and `css` files.

Alwyas create lookbook previews for the components you develop.

Every lookbook preview should have a `default` view with some variations of the component.

Don't implement a component if the Figma MCP is not available and fails and alert the developer.

#### CSS

- Use clean CSS and convert the variables to Tailwind CSS `@apply` statements where possible.
- add the new component to the `src/input.css` file.
- use the BEMCSS methodology for the component classes.

#### Figma

- check the components and see if they use other components. If so, use the existing components.

#### Files

