module Avo
  class ToolsManager
    def self.get_tools
      Avo::Tools.constants.map do |c|
        if Avo::Tools.const_get(c).is_a? Class
          "Avo::Tools::#{c}".safe_constantize
        end
      end
    end
  end
end
