require "test_helper"

class DeliveryEventsControllerTest < ActionDispatch::IntegrationTest

  test "render a list of delivery events for a trip" do
    trip = trips(:one)
    get "/trips/#{trip.id}/delivery_events"
    assert_response :success
    json_response = JSON.parse(response.body)
    assert_equal 200, json_response["status"]
    assert_equal trip.delivery_events.count, json_response["data"].length
  end

  test "allow to create a new delivery event for a trip" do
    trip = trips(:one)
    delivery_event_params = {
      event_type: "pickup",
      status: "pending",
      recipient_name: "John Doe",
      address: "123 Main St",
      scheduled_at: Time.now,
      notes: "Handle with care"
    }

    post "/trips/#{trip.id}/delivery_events", params: { delivery_event: delivery_event_params }
    assert_response :created
    json_response = JSON.parse(response.body)
    assert_equal 201, json_response["status"]
    assert_equal delivery_event_params[:event_type], json_response["data"].first["event_type"]
  end

end
