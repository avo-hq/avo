class Avo::UsersController < Avo::ActiveRecordResourcesController
  def get_users
    users = User.all.map do |user|
      {
        value: user.id,
        label: user.name
      }
    end

    render json: users
  end
end
