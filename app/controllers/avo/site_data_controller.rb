module Avo
  class SiteDataController < Avo::ApplicationController
    # The browser keeps whole pages for its Back button and only this header makes it drop them. Sign-out asks for it.
    def destroy
      head :no_content, "Clear-Site-Data" => '"cache"'
    end
  end
end
