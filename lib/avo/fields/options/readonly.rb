class Avo::Fields::Options::Readonly
  # Readonly options marks the field as disabled and not editable
  def initialize(field)
    @field = field
  end
end
