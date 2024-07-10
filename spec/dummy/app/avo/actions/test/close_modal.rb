class Avo::Actions::Test::CloseModal < Avo::BaseAction
  self.name = "Close modal"
  self.standalone = true
  self.visible = -> {
    true
  }

  def handle(**args)
    TestBuddy.hi "Hello from Avo::Actions::Test::CloseModal handle method"
    succeed "Modal closed!!"
    close_modal

    # Test custom added turbo_streams
    append_to_response -> {
      turbo_stream.set_title("Dummy action custom stream ;)")
    }
  end
end
