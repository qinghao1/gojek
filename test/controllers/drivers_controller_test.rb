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
				lattitude: 1,
				longitude: 1,
				distance: 0,
			},
			{
				id: 2,
				lattitude: 1,
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
		}
		assert_equal @response.body, expected_response
	end
