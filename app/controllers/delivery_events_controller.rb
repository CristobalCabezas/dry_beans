require "securerandom"
require "active_support/core_ext/string/inflections"

class DeliveryEventsController < ApplicationController
    def index
        begin
            @delivery_events = DeliveryEvent.all
            if params[:status]
                @delivery_events = @delivery_events.where(status: params[:status])
            end
            if params[:scheduled_date]
                @delivery_events = @delivery_events.where(scheduled_date: params[:scheduled_date])
            end
            if @delivery_events.empty?
                render json: { status: 404, data: [], errors: ["No delivery orders found"] }, status: :not_found and return
            end
            render json: { status: 200, data: @delivery_events, errors: [] } and return
        rescue StandardError => e
            render json: { status: 500, data: [], errors: [e.message] }, status: :internal_server_error
        end
    end

    def create
        begin
            trip = Trip.find(params[:trip_id])
            @delivery_event = trip.delivery_events.new(delivery_event_params)
            if @delivery_event.save
                render json: @delivery_event, status: :created
            else
                errors = @delivery_event.errors.full_messages
                render json: { error: "validation_error", message: errors }, status: :unprocessable_entity and return
            end
        rescue StandardError => e
            render json: { error: e.class.name.underscore, message: e.message }, status: :internal_server_error and return
        end
    end

    private

    def delivery_event_params
        params.require(:delivery_event).permit(:event_type, :status, :recipient_name, :address, :scheduled_at, :notes)
    end
end