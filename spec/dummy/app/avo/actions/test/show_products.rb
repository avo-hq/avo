class Avo::Actions::Test::ShowProducts < Avo::BaseAction
  self.name = "Show products"
  self.message = -> {
    names = query.map(&:title).join(", ")
    "Selected products: #{names.presence || "none"}"
  }

  def handle(query:, **args)
    names = query.map(&:title).join(", ")

    succeed "Selected products: #{names.presence || "none"}"
  end
end
