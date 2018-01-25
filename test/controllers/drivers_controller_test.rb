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
				id: 1,
        distance: 0.0,
        longitude: 1.0,
				latitude: 1.0,
			}
		].to_json
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
		put :location, {
			id: 1,
      params: {
        latitude: 1,
        longitude: 2,
        accuracy: 0.7,
      }
		}
		assert_response :success
		assert_empty @response.body
	end

	test "Decimal driver parameters" do
		put :location, {
			id: 2,
      params: {
        latitude: 1.2222,
        longitude: 2,
        accuracy: 0.7,
      }
		}
		assert_response :success
		assert_empty @response.body
	end

  test "Non-numeric driver parameters" do
    put :location, {
      id: 2,
      latitude: "string",
      longitude: 2.22333334,
    }
    assert_response 422
    expected_response = {
      errors: [
        "Latitude should be between +/- 90",
      ]
    }.to_json
    assert_equal @response.body, expected_response
  end

	test "Invalid driver id" do
		put :location, {
			id: 99999,
			latitude: 1,
			longitude: 2,
			accuracy: 0.7
		}
		assert_response :missing
		assert_empty @response.body
	end

	test "Wrong driver parameters" do
		put :location, {
			id: 1,
			latitude: 100,
			longitude: 100,
			accuracy: 0.7
		}
		assert_response 422
		expected_response = {
			errors: [
				"Latitude should be between +/- 90",
			]
		}.to_json
		assert_equal @response.body, expected_response
	end
end