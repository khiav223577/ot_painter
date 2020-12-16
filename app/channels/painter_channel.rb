class PainterChannel < ApplicationCable::Channel
  def subscribed
    stream_from "painter_channel"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
