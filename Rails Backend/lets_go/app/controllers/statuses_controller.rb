class StatusesController < ApplicationController
  before_filter :ensure_authenticated_user

  def create
    user_id = UserLookup.find_user_id_by_token(token)
    status = StatusCreator.create(params[:status], user_id)

    if status.new_record?
      render json: { errors: status.errors.messages }, status: 422
    else
      render json: { user_id: status.user_id, status_id: status.id }, status: 201
    end
  end

  def list
    #statuses = Status.where("user_id != #{current_user.id}")
    statuses = Status.where('created_at > ?', 10.minutes.ago)

    responses = statuses.map do |status|
      resp = {}
      resp[:id] = status.id
      resp[:creator_name] = status.user.try(:name) || 'Undefined'
      resp[:creator_id] = "##{status.user_id}"
      resp[:lat] = status.lat
      resp[:long] = status.long
      resp[:body] = status.body
      resp[:duration] = status.duration
      resp[:image_url] = status.try(:image_url) || ''
      resp[:created_at] = status.created_at
      resp
    end

    render json: {statuses: responses}
  end

  private
    def user_params
      params.require(:status).permit(:lat, :long, :body, :duration, :image_url)
    end
end