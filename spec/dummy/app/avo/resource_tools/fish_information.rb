class Avo::ResourceTools::FishInformation < Avo::BaseResourceTool
  self.name = "Fish information"
  # self.partial = "avo/resource_tools/_fish_information"

  def has_fish_image?(name)
    images.key? name
  end

  def images
    {
      tilapia: "https://images.unsplash.com/photo-1607629194620-a9726803827c?w=1400",
      carp: "https://images.unsplash.com/photo-1627241711138-5aca3a7545db?w=1400",
      trout: "https://images.unsplash.com/photo-1610741620547-1191d693e43d?w=1400",
      catfish: "https://images.unsplash.com/photo-1515735543535-12664d2453f8?w=1400",
      salmon: "https://images.unsplash.com/photo-1583122624875-e5621df595b3?w=1400"
    }
  end
end
