class PaintersController < ActionController::Base
  skip_before_action :verify_authenticity_token

  COMMON_ATTRIBUTES = [:deleted_at, :version].freeze
  KIND_TO_ATTRIBUTES = {
    'line'         => [:cmds, :line_width, :color, *COMMON_ATTRIBUTES].freeze,
    'pencil'       => [:cmds, :line_width, :color, *COMMON_ATTRIBUTES].freeze,
    'rounded_rect' => [:sx, :sy, :width, :height, :color, :radius, *COMMON_ATTRIBUTES].freeze,
    'sticky_note'  => [:text, :sx, :sy, :width, :height, :color, :font_size, *COMMON_ATTRIBUTES].freeze,
  }.freeze

  $objects = []

  def show
    @objects = $objects

    respond_to do |format|
      format.html
      format.json {
        render json: {
          data: {
            objects: $objects,
          },
        }
      }
    end
  end

  def create
    return render_error('invalid params') if params[:object] == nil

    available_attrs = KIND_TO_ATTRIBUTES[params[:object][:kind]]
    return render_error('invalid kind') if available_attrs == nil

    object = params[:object].slice(:kind, *available_attrs)
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

  def update
    return render_error('invalid params') if params[:object] == nil

    id = params[:object][:id].to_i
    object = $objects[id - 1]
    return render json: { data: {} } if object == nil

    available_attrs = KIND_TO_ATTRIBUTES[object['kind']]
    object.merge!(params[:object].slice(*available_attrs).permit!)

    ActionCable.server.broadcast(
      'painter_channel',
      object: object,
    )

    render json: {
      data: {
        id: id,
      },
    }
  end

  private

  def render_error(*errors, status: :bad_request)
    render json: { errors: errors }, status: status
  end
end
