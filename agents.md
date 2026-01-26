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


#### SVGs
- use `svg` helper to render the SVGs.
- use the `helpers.svg` helper to render the SVGs only in view components, never in lookbook previews.
- use a string that is composed of `tabler/outline/{NAME_OF_ICON}` or `tabler/filled/{NAME_OF_ICON}` and the name of the icon and choose an existing icon from the library. if you can't think of one use `paperclip`, `info-circle`, or `external-link` for outgoing links.

#### Tailwind CSS
- when writing css try to use the `@apply` directive whenever you can and preserve the regular Tailwind syntax.
- when writing media queries, try to land in Tailwind's regular breakpoints and write the media query as a Tailwind prefix `sm:text-sm` instead of `@media (min-width: 640px) { .text-sm { font-size: 1rem; } }`.
- we work only with Tailwind CSS v4 and above. don't try to support anything below v4.

#### Naming conventions
- use header, sidebar, and body for the component areas.
- use `title` instead of `name` when you need to reference the title of a component.

#### Node.js
- use `yarn`, not npm

#### Files
