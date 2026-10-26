class Avo::Actions::DownloadFile < Avo::BaseAction
  self.name = "Download file"
  self.standalone = true

  # TODO: fix fields for actions
  def fields
    field :read_from_file, as: :boolean, name: "Read from file", default: false
    field :read_from_pdf_file, as: :boolean, name: "Read from PDF file", default: false
    field :create_user_and_reload, as: :boolean, name: "Create user and reload", default: false
  end

  def handle(**args)
    fields = args[:fields]

    # Testing both ways
    if fields["read_from_file"]
      file = File.open(Rails.root.join("db", "seed_files", "dummy-file.txt"))

      download file.read, "dummy-file.txt"
    elsif fields["read_from_pdf_file"]
      file = File.open(Rails.root.join("db", "seed_files", "dummy-file.pdf"))

      download file.read, "dummy-file.pdf"
    elsif fields["create_user_and_reload"]
      User.create!(
        first_name: "Downloaded",
        last_name: "Statement",
        email: "downloaded-statement@avo.cool",
        password: "secret1234"
      )

      download "On the fly dummy content.", "dummy-content.txt"
      reload
    else
      download "On the fly dummy content.", "dummy-content.txt"
    end
  end
end
