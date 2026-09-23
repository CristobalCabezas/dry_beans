require "test_helper"

class TripsControllerTest < ActionDispatch::IntegrationTest
  test "render a list of trips for a route" do
    route = routes(:one)
    get "/routes/#{route.id}/trips"
    assert_response :success
    json_response = JSON.parse(response.body)
    assert_equal 200, json_response["status"]
    assert_equal route.trips.count, json_response["data"].length
  end

  test "allow to create a new trip for a route" do
    route = routes(:one)
    trip_params = {
      sequence: 1,
      driver_name: "John Doe",
      status: "pending"
    }

    post "/routes/#{route.id}/trips", params: { trip: trip_params }
    assert_response :created
    json_response = JSON.parse(response.body)
    assert_equal 201, json_response["status"]
    assert_equal trip_params[:driver_name], json_response["data"].first["driver_name"]
  end
end
