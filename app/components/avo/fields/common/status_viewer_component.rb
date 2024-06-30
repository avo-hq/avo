# frozen_string_literal: true

class Avo::Fields::Common::StatusViewerComponent < Avo::BaseComponent
	STATUS = _Union(:failed, :success, :neutral, :loading)

	prop :status, STATUS, &:to_sym
	prop :label, String
end
