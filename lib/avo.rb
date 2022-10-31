require "zeitwerk"
require_relative "avo/version"
require_relative "avo/engine" if defined?(Rails)

loader = Zeitwerk::Loader.for_gem
loader.inflector.inflect(
  "html" => "HTML",
  "uri_service" => "URIService",
  "has_html_attributes" => "HasHTMLAttributes"
)
loader.ignore("#{__dir__}/generators")
loader.setup

#                                      .//*,,.....,,*/(*
#                                   **,,..............,*#.
#                               ,*,,.....         .....*/#.
#                            **,,....             ....,*/%%
#                        ,**,,.......           . ....*/#&%
#                    **,,,...... .             . ....*/#&&%
#                **,,........ .           .     ...,//#&&&.
#            */*,,..*//***,,,,*/(,..      .. .....*//%&%&*
#         ,/**,..**/******,,***/(###,...........,//(%&&%.
#       /**,,..((//*****////((##%%%%%*.........*//%%&&%
#     ****,...#/**,,,*,*/(#%##%%%%&&&(*,.....,*/(%&&&/
#    /**,....(/*,,,,,,,*(##%%%%%&&&&&(,.....,*(#&&&&.
#  ,//*,.....(/*,,**//(##%%%%&&&&@&&%/,....,*((&&&&*
# .//*,,.....(((//(((##%%%&&&&&&&&@#/,....,*/#%&&&#
# (/**,,......###%%%%%&&&&&&&&&&@#/,,...,,*/#&&&&&
# (/**,,........%%%%%&&&&&&&&@%(*,...,,,*//(&&&&%.
# ///*,,,.........,*#&&&&#(/,,.....,,,*//(%&&&&%*
#  (//**,,,.....................,,,,*//(%&&&&&&*
#   *(///**,,,,............,,,,,,**/((&&&&&&&%.
#     ((///*****,,,,,,,,,,,,***//((&&&&&%&%&#
#       .((((////********///(((%&%&&&&%%%%%
#           (############%%%%%%%%%%%%%%%*
#               ,(############%%%%%#*

module Avo
  ROOT_PATH = Pathname.new(File.join(__dir__, ".."))
  IN_DEVELOPMENT = ENV["AVO_IN_DEVELOPMENT"] == "1"
  PACKED = !IN_DEVELOPMENT
  COOKIES_KEY = "avo"
  ENTITIES = {
    cards: ["app", "avo", "cards"],
    fields: ["app", "avo", "fields"],
    filters: ["app", "avo", "filters"],
    actions: ["app", "avo", "actions"],
    resources: ["app", "avo", "resources"],
    dashboards: ["app", "avo", "dashboards"],
    resource_tools: ["app", "avo", "resource_tools"]
  }

  class LicenseVerificationTemperedError < StandardError; end

  class LicenseInvalidError < StandardError; end

  class NotAuthorizedError < StandardError; end

  class NoPolicyError < StandardError; end
end

loader.eager_load
