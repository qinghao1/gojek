require 'test_helper'

class DriversControllerTest < ActionDispatch::IntegrationTest
  fixtures :drivers

  test "Missing customer parameters" do
    get "/drivers"
    assert_response 422
  end

  test "Correct customer parameters" do
    get "/drivers", {
      params: {
        latitude: 1,
        longitude: 1,
      }
    }
    assert_response :success
    expected_response = [
      {
        distance: 0.0,
        id: 1,
        longitude: 1.0,
        latitude: 1.0,
      }
    ].to_json
    assert_equal @response.body, expected_response
  end

  test "Correct customer parameters, further radius" do
    get "/drivers", {
      params: {
        latitude: 1,
        longitude: 1,
        radius: 2000,
      }
    }
    assert_response :success
    expected_response = [
      {
        distance: 0.0,
        id: 1,
        longitude: 1.0,
        latitude: 1.0,
      },
      {
        distance: 1111.33381293,
        id: 4,
        longitude: 1.001,
        latitude: 1.01,
      }
    ].to_json
    assert_equal @response.body, expected_response
  end

  test "Correct customer parameters but limit 0" do
    get "/drivers", {
      params: {
        latitude: 1,
        longitude: 1,
        limit: 0
      }
    }
    assert_response :success
    expected_response = [].to_json
    assert_equal @response.body, expected_response
  end

  test "Correct customer parameters but radius 0" do
    get "/drivers", {
      params: {
        latitude: 1,
        longitude: 1,
        radius: 0
      }
    }
    assert_response :success
    expected_response = [].to_json
    assert_equal @response.body, expected_response
  end

  test "Correct customer parameters but too far" do
    get "/drivers", {
      params: {
        latitude: 10,
        longitude: 10,
        radius: 1,
      }
    }
    expected_response = [].to_json
    assert_response :success
    assert_equal @response.body, expected_response
  end

  test "Wrong customer parameters (Wrong lat)" do
    get "/drivers", {
      params: {
        latitude: 100,
        longitude: 10,
        radius: 1,
      }
    }
    assert_response 422
    expected_response = {
      errors: [
        "Latitude should be between +/- 90",
      ]
    }.to_json
    assert_equal @response.body, expected_response
  end

    test "Wrong customer parameters (Wrong long)" do
    get "/drivers", {
      params: {
        latitude: 10,
        longitude: 100,
        radius: 1,
      }
    }
    assert_response 422
    expected_response = {
      errors: [
        "Longitude should be between +/- 90",
      ]
    }.to_json
    assert_equal @response.body, expected_response
  end

    test "Wrong customer parameters (Wrong lat/long)" do
    get "/drivers", {
      params: {
        latitude: 100,
        longitude: 100,
        radius: 1,
      }
    }
    assert_response 422
    expected_response = {
      errors: [
        "Latitude should be between +/- 90",
        "Longitude should be between +/- 90",
      ]
    }.to_json
    assert_equal @response.body, expected_response
  end

    test "Wrong customer parameters (Non-numeric)" do
    get "/drivers", {
      params: {
        latitude: "aaaa",
        longitude: 10,
        radius: 1,
      }
    }
    assert_response 422
    expected_response = {
      errors: [
        "Latitude should be between +/- 90",
      ]
    }.to_json
    assert_equal @response.body, expected_response
  end

  test "Correct driver parameters" do
    put_json location_driver_url(id: 33), {
      latitude: 1,
      longitude: 2,
      accuracy: 0.7,
    }
    assert_response :success
    expected_response = {}.to_json
    assert_equal @response.body, expected_response
  end

  test "Decimal driver parameters" do
    put_json location_driver_url(id: 33), {
      latitude: 1.111,
      longitude: 2.2222,
      accuracy: 0.7,
    }
    assert_response :success
    expected_response = {}.to_json
    assert_equal @response.body, expected_response
  end

  test "Wrong driver parameters (Non-numeric)" do
    put_json location_driver_url(id: 33), {
      latitude: "string",
      longitude: 2.2222,
      accuracy: 0.7,
    }
    assert_response 422
    expected_response = {
      errors: [
        "Latitude should be between +/- 90",
      ]
    }.to_json
    assert_equal @response.body, expected_response
  end

  test "Non-numeric driver parameters (Long)" do
    put_json location_driver_url(id: 33), {
      longitude: "string",
      latitude: 2.2222,
      accuracy: 0.7,
    }
    assert_response 422
    expected_response = {
      errors: [
        "Longitude should be between +/- 90",
      ]
    }.to_json
    assert_equal @response.body, expected_response
  end

  test "Invalid driver id" do
    put_json location_driver_url(id: 99999), {
      longitude: 1.222,
      latitude: 2.2222,
      accuracy: 0.7,
    }
    expected_response = {}.to_json
    assert_equal @response.body, expected_response
  end

  test "Wrong driver parameters (Lat/Long)" do
    put_json location_driver_url(id: 44), {
      longitude: 100,
      latitude: 100,
      accuracy: 0.7,
    }
    assert_response 422
    expected_response = {
      errors: [
        "Latitude should be between +/- 90",
        "Longitude should be between +/- 90",
      ]
    }.to_json
    assert_equal @response.body, expected_response
  end

  test "Wrong driver parameters (Lat)" do
    put_json location_driver_url(id: 44), {
      longitude: 10,
      latitude: 100,
      accuracy: 0.7,
    }
    assert_response 422
    expected_response = {
      errors: [
        "Latitude should be between +/- 90",
      ]
    }.to_json
    assert_equal @response.body, expected_response
  end

  test "Wrong driver parameters (Long)" do
    put_json location_driver_url(id: 44), {
      longitude: 100,
      latitude: 10,
      accuracy: 0.7,
    }
    assert_response 422
    expected_response = {
      errors: [
        "Longitude should be between +/- 90",
      ]
    }.to_json
    assert_equal @response.body, expected_response
  end

  test "Wrong driver parameters (Accuracy)" do
    put_json location_driver_url(id: 44), {
      longitude: 10,
      latitude: 10,
      accuracy: 500,
    }
    assert_response 422
    expected_response = {
      errors: [
        "Accuracy should be between 0 and 1",
      ]
    }.to_json
    assert_equal @response.body, expected_response
  end

  test "Wrong driver parameters (Missing long)" do
    put_json location_driver_url(id: 44), {
      latitude: 10,
      accuracy: 1,
    }
    assert_response 422
    expected_response = {
      errors: [
        "Longitude should be between +/- 90",
      ]
    }.to_json
    assert_equal @response.body, expected_response
  end

  test "Wrong driver parameters (Missing lat)" do
    put_json location_driver_url(id: 44), {
      longitude: 10,
      accuracy: 1,
    }
    assert_response 422
    expected_response = {
      errors: [
        "Latitude should be between +/- 90",
      ]
    }.to_json
    assert_equal @response.body, expected_response
  end

  test "Wrong driver parameters (Weird lat)" do
    put_json location_driver_url(id: 44), {
      latitude: "dsdsdsds!",
      longitude: 10,
      accuracy: 1,
    }
    assert_response 422
    expected_response = {
      errors: [
        "Latitude should be between +/- 90",
      ]
    }.to_json
    assert_equal @response.body, expected_response
  end

  test "Wrong driver parameters (Weird long)" do
    put_json location_driver_url(id: 44), {
      latitude: 10,
      longitude: "ffff",
      accuracy: 1,
    }
    assert_response 422
    expected_response = {
      errors: [
        "Longitude should be between +/- 90",
      ]
    }.to_json
    assert_equal @response.body, expected_response
  end

  test "Update existing driver" do
    put_json location_driver_url(id: 3), {
      longitude: 10,
      latitude: 10,
      accuracy: 0.5,
    }
    assert_response 200
    expected_response = {}.to_json
    assert_equal @response.body, expected_response
    driver = Driver.find(3)
    assert(
      driver.lonlat.longitude == 10.to_f
    )
    assert(
      driver.lonlat.longitude == 10.to_f
    )
    assert(
      driver.accuracy == 0.5
    )
  end
end