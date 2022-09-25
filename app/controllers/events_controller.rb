class EventsController < ApplicationController
  include ParamsSupport

  before_action :current_event, only: %i[show update destroy]

  def index
    render json: current_user.events.map(&:to_h), status: :ok
  end

  def show
    render json: current_event.to_h, status: :ok
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

  def update
    if params[:start_date].present? && !iso8601_date?(params[:start_date])
      raise BadRequest,
            "Invalid date format (#{params[:start_date]}) format. Dates need to be in iso8601 format"
    end

    if current_event.update!(event_params)
      render json: current_event.to_h
    else
      render json: current_event.errors, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordInvalid => e
    render json: { message: e.message, code: 'unprocessable_entity' }, status: :unprocessable_entity
  end

  def destroy
    current_event.destroy!
    render json: { message: 'success' }, status: :ok
  rescue ActiveRecord::RecordNotDestroyed
    raise EntityDeletionError, current_event
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

  def current_event
    @event = Event.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    raise EntityNotFound, Event
  end

end
