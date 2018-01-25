class DriversController < ApplicationController
  def index
    begin
      # Check for errors:
      errors = []
      sanitized = sanitize_and_normalize_params(params)

      # Check latitude
      if !valid_coord(sanitized[:longitude])
        errors.push "Latitude should be between +/- 90"
      end
      # Check longitude
      if !valid_coord(sanitized[:longitude])
        errors.push "Longitude should be between +/- 90"
      end

      # Return 422 response if there are errors
      if !errors.empty?
        render({
          json: {
            errors: errors,
          },
          status: :unprocessable_entity,
        })
      # Else, render successful response
      else
        render({
          json: closest_drivers(sanitized).to_json,
        })
      end
    rescue ActionController::ParameterMissing
        render({
          json: {
            errors: ["Missing latitude and/or longitude"],
          },
          status: :unprocessable_entity,
        })
    end
  end

  # Helper methods
  private
  def sanitize_and_normalize_params(params)
    params
    .permit(
      :latitude,
      :longitude,
      :radius,
      :limit,
    )
    .require(
      [
        :latitude,
        :longitude,
      ]
    )

    params[:latitude] = params[:latitude].to_f
    params[:longitude] = params[:longitude].to_f
    params[:radius] = params[:radius] ? params[:radius].to_f : 500
    params[:limit] = params[:limit] ? params[:limit].to_f : 10

    return params
  end

  # Returns driver objects given query parameters in params
  def closest_drivers(sanitized_params)
    # Important: Parameters must be sanitized because
    # can't use in-built ActiveRecord protections with PostGIS

    distance_query = 
      Driver
      .select(
        "ST_Distance(
          lonlat, 
          'POINT(#{sanitized_params[:longitude]} #{sanitized_params[:latitude]})'
        ) AS distance",
        "id",
        "ST_X(lonlat::geometry) AS longitude",
        "ST_Y(lonlat::geometry) AS latitude"
      )
      .to_sql

    restricted_distance_query = 
    "SELECT * FROM (#{distance_query}) dq "\
    "WHERE dq.distance < #{sanitized_params[:radius]} "\
    "ORDER BY dq.distance "\
    "LIMIT #{sanitized_params[:limit]} "

    return ActiveRecord::Base.connection.execute(restricted_distance_query)
  end

  def valid_coord(lonlat)
    return (lonlat >= -90 and lonlat <= 90)
  end
end
