class DummyAction < Avo::BaseAction
  self.name = "Dummy action"
  self.standalone = true

  def handle(fields:)
    # Do something here
    succeed 'Yup'
  end
end
