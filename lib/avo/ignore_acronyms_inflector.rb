module Avo
  # A Zeitwerk inflector that deliberately ignores global ActiveSupport acronyms
  # when camelizing file basenames. This keeps Avo internals predictable even if
  # the host app defines acronyms like "URL".
  class IgnoreAcronymsInflector < Zeitwerk::Inflector
    # Camelize a basename in the conventional way, ignoring ActiveSupport acronyms.
    # For example, "url_helpers" -> "UrlHelpers" (not "URLHelpers").
    def camelize(basename, _abspath)
      basename.split("_").map! { |segment| segment.capitalize }.join
    end
  end
end


