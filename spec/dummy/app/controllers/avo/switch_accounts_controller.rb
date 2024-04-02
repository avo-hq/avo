class Avo::SwitchAccountsController < Avo::ApplicationController
  def update
    session[:tenant_id] = params[:id]

    redirect_back fallback_location: root_path
  end
end
