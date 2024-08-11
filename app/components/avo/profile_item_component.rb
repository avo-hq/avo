# frozen_string_literal: true

class Avo::ProfileItemComponent < Avo::BaseComponent
  attr_reader :label
  attr_reader :icon
  attr_reader :path
  attr_reader :active
  attr_reader :target
  attr_reader :method
  attr_reader :params
  attr_reader :classes

  prop :label, _Nilable(String), reader: :public
  prop :icon, _Nilable(String), reader: :public
  prop :path, _Nilable(String), reader: :public
  prop :active, Symbol, default: :inclusive, reader: :public do |value|
    value&.to_sym
  end
  prop :target, _Nilable(Symbol), reader: :public do |value
    value&.to_sym
  end
  prop :title, _Nilable(String), reader: :public
  prop :method, _Nilable(String), reader: :public
  prop :params, Hash, default: {}.freeze, reader: :public
  prop :classes, String, default: "", reader: :public

  def title
    @title || @label
  end

  private

  def button_classes
    "flex-1 flex items-center justify-center bg-white text-left cursor-pointer text-gray-800 font-semibold hover:bg-primary-100 block px-4 py-1 w-full py-3 text-center rounded w-full"
  end
end
