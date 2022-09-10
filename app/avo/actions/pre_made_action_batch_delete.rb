module Actions
  class PreMadeActionBatchDelete < Avo::BaseAction
    self.name = I18n.t('avo.delete').capitalize
    self.message = I18n.t('avo.are_you_sure').capitalize
    self.confirm_button_label = I18n.t('avo.delete').capitalize

    def handle(**args)
      models, fields, current_user, resource = args.values_at(:models, :fields, :current_user, :resource)

      models.each(&:destroy!)

      silent
    end
  end
end
