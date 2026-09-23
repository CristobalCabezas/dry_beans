require "securerandom"
require "active_support/core_ext/string/inflections"

class DeliveryEventsController < ApplicationController
    def show
        begin
            begin
                trip = Trip.find(params[:trip_id])
                @delivery_events = trip.delivery_events
                if @delivery_events.empty?
                    render json: { status: 404, data: [], errors: ["No delivery orders found"] }, status: :not_found and return
                end
            rescue ActiveRecord::RecordNotFound
                render json: { status: 404, data: [], errors: ["Trip not found"] }, status: :not_found and return
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
                render json: { status: 422, data: [], errors: errors }, status: :unprocessable_entity and return
            end
        rescue StandardError => e
            render json: { status: 500, data: [], errors: [e.message] }, status: :internal_server_error and return
        end
    end

    private

    def delivery_event_params
        params.require(:delivery_event).permit(:event_type, :status, :recipient_name, :address, :scheduled_at, :notes)
    end
end