require "securerandom"

class RoutesController < ApplicationController
    def index
        begin
            @routes = Route.includes(trips: :delivery_events).all

            if @routes.empty?
                render json: { status: 404, data: [], errors: ["No routes found"] }, status: :not_found and return
            end

            result = @routes.as_json(include: { trips: { include: :delivery_events } })
            render json: { status: 200, data: result, errors: [] } and return
        rescue => e
            render json: { status: 500, data: [], errors: [e.message] }, status: :internal_server_error and return
        end
    end

    def show
        begin
            begin
                route = Route.includes(trips: :delivery_events).find(params[:id])
            rescue ActiveRecord::RecordNotFound
                render json: { status: 404, data: [], errors: ["Route not found"] }, status: :not_found and return
            end
            result = route.as_json(include: { trips: { include: :delivery_events } })
            render json: { status: 200, data: [result], errors: [] } and return
        rescue => e
            render json: { status: 500, data: [], errors: [e.message] }, status: :internal_server_error and return
        end
    end

    def create
        begin
            @route = Route.new(route_params)
            if @route.save
                render json: { status: 201, data: [@route], errors: [] }, status: :created and return
            else
                render json: { status: 422, data: [], errors: @route.errors.full_messages }, status: :unprocessable_entity and return
            end
        rescue => e
            render json: { status: 500, data: [], errors: [e.message] }, status: :internal_server_error and return
        end
    end

    private

    def route_params
        params.require(:route).permit(:code, :route_date, :status)
    end
end
