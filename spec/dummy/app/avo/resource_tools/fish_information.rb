class FishInformation < Avo::BaseResourceTool
  self.name = "Fish information"

  def has_fish_image?(name)
    images.key? name
  end

  def images
    {
      tilapia: "https://images.unsplash.com/photo-1607629194620-a9726803827c",
      carp: "https://images.unsplash.com/photo-1627241711138-5aca3a7545db",
      trout: "https://images.unsplash.com/photo-1610741620547-1191d693e43d",
      catfish: "https://images.unsplash.com/photo-1515735543535-12664d2453f8",
      salmon: "https://images.unsplash.com/photo-1583122624875-e5621df595b3"
    }
  end
end
