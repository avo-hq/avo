class Avo::Actions::DownloadFile < Avo::BaseAction
  self.name = "Download file"
  self.standalone = true
  self.may_download_file = true

  # TODO: fix fields for actions
  def fields
    field :read_from_file, as: :boolean, name: "Read from file", default: false
  end

  def handle(**args)
    fields = args[:fields]

    # Testing both ways
    if fields["read_from_file"]
      file = File.open(Avo::Engine.root.join("spec", "dummy", "dummy-file.txt"))

      download file.read, "dummy-file.txt"
    else
      download "On the fly dummy content.", "dummy-content.txt"
    end
  end
end
