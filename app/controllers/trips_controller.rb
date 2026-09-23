class TripsController < ApplicationController
    def show
        begin
            begin
                route = Route.find(params[:route_id])
                @trips = route.trips
                if @trips.empty?
                    render json: { status: 404, data: [], errors: ["No trips found"] }, status: :not_found and return
                end
            rescue ActiveRecord::RecordNotFound
                render json: { status: 404, data: [], errors: ["Route not found"] }, status: :not_found and return
            end
            render json: { status: 200, data: @trips, errors: [] } and return
        rescue StandardError => e
            render json: { status: 500, data: [], errors: [e.message] }, status: :internal_server_error
        end
    end

    def create
        begin
            route = Route.find(params[:route_id])
            @trip = route.trips.new(trip_params)
            if @trip.save
                render json: { status: 201, data: [@trip], errors: [] }, status: :created and return
            else
                render json: { status: 422, data: [], errors: @trip.errors.full_messages }, status: :unprocessable_entity and return
            end
        rescue StandardError => e
            render json: { status: 500, data: [], errors: [e.message] }, status: :internal_server_error and return
        end
    end

    private

    def trip_params
        params.require(:trip).permit(:route_id, :sequence, :driver_name, :status)
    end
end
