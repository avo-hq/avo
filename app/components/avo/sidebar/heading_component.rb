# frozen_string_literal: true

class Avo::Sidebar::HeadingComponent < Avo::BaseComponent
  prop :label, _Nilable(String), reader: :public
  prop :icon, _Nilable(String), reader: :public
  prop :collapsable, _Boolean, default: false, reader: :public
  prop :collapsed, _Boolean, default: false, reader: :public
  prop :key, _Nilable(_Boolean), default: false, reader: :public
end
