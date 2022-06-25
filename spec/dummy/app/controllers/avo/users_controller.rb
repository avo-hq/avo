class Avo::UsersController < Avo::ResourcesController
  def create
    super do |record|
      record.notify("User created")
    end
  end

  def update
    super do |record|
      record.notify("User updated")
    end
  end

  def destroy
    super do
      puts "User destroyed"
    end
  end
end
