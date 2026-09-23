require "test_helper"

class RoutesControllerTest < ActionDispatch::IntegrationTest
  test "render a list of routes" do
    get "/routes"
    assert_response :success
    json_response = JSON.parse(response.body)
    assert_equal 200, json_response["status"]
    assert_equal Route.count, json_response["data"].length
  end

  test "render a specific route" do
    route = routes(:one)
    get "/routes/#{route.id}"
    assert_response :success
    json_response = JSON.parse(response.body)
    assert_equal 200, json_response["status"]
    assert_equal route.code, json_response["data"].first["code"]
  end

  test "allow to create a new route" do
    route_params = {
      code: "RUTA-CONCE-001",
      route_date: Date.today,
      status: "in_progress"
    }

    post "/routes", params: { route: route_params }
    assert_response :created
    json_response = JSON.parse(response.body)
    assert_equal 201, json_response["status"]
    assert_equal route_params[:code], json_response["data"].first["code"]
  end
end
