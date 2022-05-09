class AvoChannel < ApplicationCable::Channel
  def subscribed
    # puts ["self->", "#{params[:id]}:#{current_user.id}"].inspect
    # stream_from "avo:#{params[:resource_name]}:#{params[:resource_id]}"
    stream_from "avo"
  end
end
