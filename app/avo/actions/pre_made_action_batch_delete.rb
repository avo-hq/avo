# frozen_string_literal: true

module Actions
  class PreMadeActionBatchDelete < Avo::BaseAction
    self.name = I18n.t('avo.delete').capitalize
    self.message = I18n.t('avo.are_you_sure').capitalize
    self.confirm_button_label = I18n.t('avo.delete').capitalize

    def handle(**args)
      models, = args.values_at(:models, :fields, :current_user, :resource)

      models.each(&:destroy!)

      inform I18n.t(
        'avo.resource_batch_destroyed',
        records: I18n.t('avo.record', count: models.size),
        destroyed: I18n.t('avo.destroyed', count: models.size)
      )
    rescue StandardError => e
      fail e
    end
  end
end
