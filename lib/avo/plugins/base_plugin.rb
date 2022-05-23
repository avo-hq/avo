class Avo::Plugins::BasePlugin
  attr_reader :request
  attr_reader :context
  attr_reader :current_user
  attr_reader :root_path
  attr_reader :view_context
  attr_reader :params

  def initialize(request: nil, context: nil, current_user: nil, root_path: nil, view_context: nil, params: nil)
    @request = request
    @context = context
    @current_user = current_user
    @root_path = root_path
    @view_context = view_context
    @params = params
  end

  def on_init
  end
end
