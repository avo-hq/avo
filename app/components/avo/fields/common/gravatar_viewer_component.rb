# frozen_string_literal: true

class Avo::Fields::Common::GravatarViewerComponent < Avo::BaseComponent
  prop :md5, _Nilable(String)
  prop :link, _Nilable(String)
  prop :default, _Nilable(String)
  prop :size, _Nilable(Integer)
  prop :rounded, _Boolean, default: false
  prop :link_to_record, _Boolean, default: false
  prop :title, _Nilable(String)
end
