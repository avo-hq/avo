# frozen_string_literal: true

class Avo::Sidebar::HeadingComponent < Avo::BaseComponent
  prop :label, _Nilable(String)
  prop :icon, _Nilable(String)
  prop :collapsable, _Boolean, default: false
  prop :collapsed, _Boolean, default: false
  prop :key, _Nilable(String)
end
