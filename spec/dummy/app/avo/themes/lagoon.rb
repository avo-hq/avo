# A local theme fixture: CSS, a partial override (_footer) and a brand asset,
# so request and system specs exercise every override kind through the
# app-side path (app/avo/themes + app/views/avo/themes/<id>).
class Avo::Themes::Lagoon < Avo::BaseTheme
  self.title = "Lagoon"
  self.description = "Dummy-app local theme fixture."
  self.appearance = {
    logo: "avo/themes/lagoon/logo.svg",
    chart_colors: %w[#0E7490 #14B8A6 #A3E635]
  }
end
