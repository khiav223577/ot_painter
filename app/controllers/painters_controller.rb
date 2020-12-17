class PaintersController < ActionController::Base
  skip_before_action :verify_authenticity_token

  $objects = []

  def show
    @objects = $objects

    respond_to do |format|
      format.html
    end
  end

  def update
    return render_error('invalid params') if params[:object] == nil

    object = params[:object].slice(:kind, :cmds, :version, :width, :color)
    object['id'] = $objects.size + 1
    object['width'] = object['width'].to_i if object['width'].is_a?(String)

    $objects << object

    ActionCable.server.broadcast(
      'painter_channel',
      object: object,
    )

    render json: {
      data: {
        id: object['id'],
      },
    }
  end

  private

  def render_error(*errors, status: :bad_request)
    render json: { errors: errors }, status: status
  end
end
