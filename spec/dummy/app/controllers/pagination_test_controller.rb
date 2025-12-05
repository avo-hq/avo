class PaginationTestController < ApplicationController
  include Pagy::Backend

  def index
    @pagy, @users = pagy(User.order(:id), limit: params[:per_page] || 24)
  end
end
