class Avo::Resources::Event < Avo::BaseResource
  self.title = :name
  self.description = "An event that happened at a certain time."
  self.includes = [:location]

  self.cover_photo = {
    # size: :sm,
    visible_on: [:show, :index],
    source: -> {
      if record.present?
        record.cover_photo
      else
        Event.first&.cover_photo
      end
    }
  }
  self.profile_photo = {
    source: :profile_photo
  }
  self.discreet_information = :timestamps

  self.row_controls_config = {
    float: true,
    show_on_hover: true,
    placement: :right
  }

  def fields
    field :name, as: :text, link_to_record: true, sortable: true, stacked: true
    field :first_user,
      as: :record_link,
      meta: -> {
        :foo
      }
    field :event_time, as: :datetime, sortable: true
    field :body,
      as: :trix,
      meta: {
        foo: :bar,
      }

    field :profile_photo, as: :file, is_image: true, only_on: :forms
    field :cover_photo, as: :file, is_image: true, only_on: :forms

    if params[:show_location_field] == "1"
      # Example for error message when resource is missing
      field :location, as: :belongs_to
    end

    # this field demonstrated how one can use the array field to display an arbitrary array of objects as a "has_many field"
    field :attendees, as: :array do
      [
        {id: 1, name: "John Doe", role: "Software Developer", organization: "TechCorp"},
        {id: 2, name: "Jane Smith", role: "Data Scientist", organization: "DataPros"},
        {id: 3, name: "Emily Davis", role: "Product Manager", organization: "Startup Inc."},
        {id: 4, name: "Kevin Roberts", role: "CTO", organization: "FutureTech"},
        {id: 5, name: "Sarah Johnson", role: "UI/UX Designer", organization: "DesignWorks"},
        {id: 6, name: "Michael Lee", role: "Backend Engineer", organization: "CodeBase"},
        {id: 7, name: "Olivia Brown", role: "Project Coordinator", organization: "BuildIt"},
        {id: 8, name: "Ethan Williams", role: "AI Specialist", organization: "InnoBots"},
        {id: 9, name: "Sophia Martinez", role: "Marketing Strategist", organization: "Brandify"},
        {id: 10, name: "Jacob Wilson", role: "DevOps Engineer", organization: "OpsWorld"},
        {id: 11, name: "Ava Taylor", role: "Business Analyst", organization: "AnalyzeNow"},
        {id: 12, name: "William Hernandez", role: "Full Stack Developer", organization: "Webify"},
        {id: 13, name: "Mia Moore", role: "HR Manager", organization: "PeopleFirst"},
        {id: 14, name: "James Anderson", role: "Blockchain Developer", organization: "ChainWorks"},
        {id: 15, name: "Charlotte White", role: "Product Designer", organization: "Cre8tive"},
        {id: 16, name: "Benjamin Green", role: "Cybersecurity Analyst", organization: "SecureNet"},
        {id: 17, name: "Amelia Clark", role: "Data Engineer", organization: "BigData Solutions"},
        {id: 18, name: "Lucas Carter", role: "Scrum Master", organization: "AgileHub"},
        {id: 19, name: "Ella Thompson", role: "Software Architect", organization: "CodeVision"},
        {id: 20, name: "Alexander Scott", role: "Solutions Consultant", organization: "Innovate Consulting"}
      ]
    end
  end
end
