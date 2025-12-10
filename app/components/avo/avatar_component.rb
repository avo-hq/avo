class Avo::AvatarComponent < Avo::BaseComponent
  SIZES = %w[large medium small tiny].freeze
  SHAPES = %w[rounded square].freeze
  THEMES = %w[default orange yellow green teal blue purple].freeze
  TYPES = %w[avatar placeholder initial].freeze

  def initialize(
    type: "placeholder",
    size: "large",
    shape: "rounded",
    theme: "default",
    initial: nil,
    src: nil,
    alt: nil,
    **options
  )
    @type = type.to_s
    @size = size.to_s
    @shape = shape.to_s
    @theme = theme.to_s
    @initial = initial
    @src = src
    @alt = alt
    @options = options

    validate_params!
  end

  private

  attr_reader :type, :size, :shape, :theme, :initial, :src, :alt, :options

  def validate_params!
    raise ArgumentError, "Invalid type: #{type}" unless TYPES.include?(type)
    raise ArgumentError, "Invalid size: #{size}" unless SIZES.include?(size)
    raise ArgumentError, "Invalid shape: #{shape}" unless SHAPES.include?(shape)
    raise ArgumentError, "Invalid theme: #{theme}" unless THEMES.include?(theme)

    if type == "initial" && initial.blank?
      raise ArgumentError, "Initial is required when type is 'initial'"
    end

    if type == "avatar" && src.blank?
      raise ArgumentError, "src is required when type is 'avatar'"
    end
  end

  def container_classes
    classes = [ "cado-avatar" ]
    classes << "cado-avatar--#{type}"
    classes << "cado-avatar--#{size}"
    classes << "cado-avatar--#{shape}"
    classes << "cado-avatar--#{theme}" unless theme == "default"
    classes.join(" ")
  end

  def image_classes
    "cado-avatar__image"
  end

  def initial_classes
    "cado-avatar__initial"
  end

  def border_classes
    "cado-avatar__border"
  end

  def display_initial
    return "" if initial.blank?
    initial.to_s.first.upcase
  end
end
