class ResourceShowChannel < ApplicationCable::Channel
  def subscribed
    # puts ["self->", "#{params[:id]}:#{current_user.id}"].inspect
    # stream_from "avo:#{params[:resource_name]}:#{params[:resource_id]}"
    tag = "resource_show:#{params[:resource_name]}:#{params[:resource_id]}"
    puts ["tag subscribed->", tag].inspect
    stream_from tag
    # stream_from "resource:#{params[]}"
    # stream_from "ResourceShow"
  end
end
