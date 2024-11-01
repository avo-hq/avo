# frozen_string_literal: true

class Avo::ProfileItemComponent < Avo::BaseComponent
  prop :label, reader: :public
  prop :icon, reader: :public
  prop :path, reader: :public
  prop :active, default: :inclusive, reader: :public do |value|
    value&.to_sym
  end
  prop :target, reader: :public do |value|
    value&.to_sym
  end
  prop :title, reader: :public
  prop :method, reader: :public
  prop :params, default: {}.freeze, reader: :public
  prop :classes, default: "", reader: :public

  def title
    @title || @label
  end

  private

  def button_classes
    "flex-1 flex items-center justify-center bg-white text-left cursor-pointer text-gray-800 font-semibold hover:bg-primary-100 block px-4 py-1 w-full py-3 text-center rounded w-full"
  end
end
