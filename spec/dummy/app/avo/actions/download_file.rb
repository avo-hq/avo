class Avo::Actions::DownloadFile < Avo::BaseAction
  self.name = "Download file"
  self.standalone = true

  # TODO: fix fields for actions
  def fields
    field :read_from_file, as: :boolean, name: "Read from file", default: false
    field :read_from_pdf_file, as: :boolean, name: "Read from PDF file", default: false
  end

  def handle(**args)
    fields = args[:fields]

    # Testing both ways
    if fields["read_from_file"]
      file = File.open(Avo::Engine.root.join("spec", "dummy", "dummy-file.txt"))

      download file.read, "dummy-file.txt"
    elsif fields["read_from_pdf_file"]
      file = File.open(Avo::Engine.root.join("spec", "dummy", "dummy-file.pdf"))

      download file.read, "dummy-file.pdf"
    else
      download "On the fly dummy content.", "dummy-content.txt"
    end
  end
end
