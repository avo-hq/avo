class Avo::Actions::Test::DoNothing < Avo::BaseAction
  self.name = "Do Nothing"
  self.standalone = true
  self.visible = -> {
    true
  }

  def handle(**args)
    TestBuddy.hi "Hello from Avo::Actions::Test::DoNothing handle method"
    succeed "Nothing Done!!"
    do_nothing
  end
end
