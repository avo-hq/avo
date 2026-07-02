class PagyOutsideAvoController < ApplicationController
  include Pagy::Method

  def index
    @pagy, @posts = pagy(Post.order(created_at: :desc), limit: 5)
  end
end
