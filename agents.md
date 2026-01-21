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
- when the width and height are the same, use the `size-` class instead of `width-` and `height-`.
- don't use `left`/`right` modifiers as we need to support RTL. Use `start`/`end` instead. Same for short names like `ml`, `mr`, `pl`, `pr`, `left`, `right`, etc.

#### Figma

- check the components and see if they use other components. If so, use the existing components.

#### Files

## Javascript

We use StimulusJS for the javascript.
Aboid writing inline script tags in the HTML unless instructed so or mentioned some kind of "temporary" or "quick" solution .

## HTML Structure

When toggling the visibility of some html elements, use the `hidden` HTML attribute instead of the `hidden` class.

## Ruby on Rails

Whenever possible use the `partial:` keyword when rendering partials unless needed otherwise.
