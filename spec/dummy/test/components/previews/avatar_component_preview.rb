class AvatarComponentPreview < ViewComponent::Preview
  # @!group Types

  # Placeholder avatar (default state)
  def placeholder
    render Avo::UI::AvatarComponent.new(type: "placeholder")
  end

  # Avatar with image
  def with_image
    render Avo::UI::AvatarComponent.new(
      type: "avatar",
      src: "https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=400&h=400&fit=crop&crop=face",
      alt: "John Doe"
    )
  end

  # Avatar with initials
  def with_initials
    render Avo::UI::AvatarComponent.new(
      type: "initials",
      initials: "JD"
    )
  end

  # @!endgroup

  # @!group Interactive Playground

  # Interactive avatar with customizable options
  # @param type select { choices: [placeholder, avatar, initials] } "Avatar type"
  # @param size select { choices: [large, medium, small, tiny] } "Avatar size"
  # @param shape select { choices: [rounded, square] } "Avatar shape"
  # @param theme select { choices: [default, orange, yellow, green, teal, blue, purple] } "Color theme"
  # @param initials text "Initials text (for initials type)"
  # @param image_url url "Image URL (for avatar type)"
  # @param alt_text text "Alt text for image"
  def playground(
    type: "initials",
    size: "large",
    shape: "rounded",
    theme: "blue",
    initials: "JD",
    image_url: "https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=400&h=400&fit=crop&crop=face",
    alt_text: "User Avatar"
  )
    render_with_template(
      template: "avatar_component_preview/playground",
      locals: {
        type: type,
        size: size,
        shape: shape,
        theme: theme,
        initials: initials,
        image_url: image_url,
        alt_text: alt_text
      }
    )
  end

  # Size comparison with toggles
  # @param show_labels toggle "Show size labels"
  # @param background_color select { choices: [white, gray, dark] } "Background color"
  # @param avatar_type select { choices: [placeholder, initials, avatar] } "Avatar type to show"
  def size_comparison(
    show_labels: true,
    background_color: "white",
    avatar_type: "initials"
  )
    render_with_template(
      template: "avatar_component_preview/size_comparison",
      locals: {
        show_labels: show_labels,
        background_color: background_color,
        avatar_type: avatar_type
      }
    )
  end

  # Theme showcase with personalization
  # @param user_initials text "Your initials"
  # @param show_names toggle "Show theme names"
  # @param avatar_size select { choices: [large, medium, small, tiny] } "Avatar size"
  # @param avatar_shape select { choices: [rounded, square] } "Avatar shape"
  def theme_showcase(
    user_initials: "A",
    show_names: true,
    avatar_size: "large",
    avatar_shape: "rounded"
  )
    render_with_template(
      template: "avatar_component_preview/theme_showcase",
      locals: {
        user_initials: user_initials,
        show_names: show_names,
        avatar_size: avatar_size,
        avatar_shape: avatar_shape
      }
    )
  end

  # Custom avatar gallery
  # @param custom_images textarea "Custom image URLs (one per line)"
  # @param gallery_size select { choices: [large, medium, small, tiny] } "Gallery avatar size"
  # @param gallery_shape select { choices: [rounded, square] } "Gallery avatar shape"
  def custom_gallery(
    custom_images: "https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=400&h=400&fit=crop&crop=face\nhttps://images.unsplash.com/photo-1494790108755-2616b612b5bb?w=400&h=400&fit=crop&crop=face\nhttps://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&h=400&fit=crop&crop=face\nhttps://images.unsplash.com/photo-1517841905240-472988babdf9?w=400&h=400&fit=crop&crop=face",
    gallery_size: "medium",
    gallery_shape: "rounded"
  )
    render_with_template(
      template: "avatar_component_preview/custom_gallery",
      locals: {
        custom_images: custom_images,
        gallery_size: gallery_size,
        gallery_shape: gallery_shape
      }
    )
  end

  # @!endgroup

  # @!group Standard Examples

  # All variants showcase
  def showcase
    render_with_template(template: "avatar_component_preview/showcase")
  end

  # Different sizes
  def sizes
    render_with_template(template: "avatar_component_preview/sizes")
  end

  # Different shapes
  def shapes
    render_with_template(template: "avatar_component_preview/shapes")
  end

  # Different color themes for initials
  def themes
    render_with_template(template: "avatar_component_preview/themes")
  end

  # @!endgroup
end
