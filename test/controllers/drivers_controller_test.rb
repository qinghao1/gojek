require 'test_helper'

class DriversControllerTest < ActionDispatch::IntegrationTest
	test "Missing customer parameters" do
		get :index
		assert_response 422
	end

	test "Correct customer parameters" do
		get :index, {
			latitude: 1,
			longitude: 1,
		}
		assert_response :success
		expected_response = [
			{
				id: 1,
				latitude: 1,
				longitude: 1,
				distance: 0,
			},
			{
				id: 2,
				latitude: 1,
				longitude: 2,
				distance: 1,
			}
		].to_json
		assert_equal @response.body, expected_response
	end

	test "Correct customer parameters but too far" do
		get :index, {
			latitude: 10,
			longitude: 10,
			radius: 1,
		}
		assert_response :success
		assert_empty @response.body
	end

	test "Wrong customer parameters" do
		get :index, {
			latitude: 100,
			longitude: 100,
			radius: 1,
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
		get :location, {
			id: 1,
			latitude: 1,
			longitude: 2,
			accuracy: 0.7
		}
		assert_response :success
		assert_empty @response.body
	end

	test "Decimal driver parameters" do
		get :location, {
			id: 2,
			latitude: 1.12211212,
			longitude: 2.22333334,
			accuracy: 0.7
		}
		assert_response :success
		assert_empty @response.body
	end

	test "Invalid driver id" do
		get :location, {
			id: 99999,
			latitude: 1,
			longitude: 2,
			accuracy: 0.7
		}
		assert_response :missing
		assert_empty @response.body
	end

	test "Wrong driver parameters" do
		get :location, {
			id: 1
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