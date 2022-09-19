class EventsController < ApplicationController
  include ParamsSupport

  def index
    render json: current_user.events.map(&:to_h), status: :ok
  end

  def create
    if params[:start_date].present? && !iso8601_date?(params[:start_date])
      raise BadRequest,
            "Invalid date format (#{params[:start_date]}) format. Dates need to be in iso8601 format"
    end

    event = current_user.events.new(event_params)

    if event.save
      render json: event.to_h
    else
      render json: event.errors, status: :unprocessable_entity
    end
  end

  private

  def event_params
    params
      .require(:event)
      .permit(:title, :start_date, :unit)
  end

  def current_user
    current_token.user
  end

end
