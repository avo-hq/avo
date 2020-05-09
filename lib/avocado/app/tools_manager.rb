module Avocado
  class ToolsManager
    def self.get_tools
      Avocado::Tools.constants.map do |c|
        if Avocado::Tools.const_get(c).is_a? Class
          "Avocado::Tools::#{c}".safe_constantize
        end
      end
    end
  end
end
