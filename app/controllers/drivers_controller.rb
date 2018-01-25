class DriversController < ApplicationController
  def index
    # Check for errors:
    errors = []

    begin
      sanitized = sanitize_and_normalize_params(params)
    rescue ActionController::ParameterMissing
      errors.push "Missing latitude and/or longitude"
    end
    # Check latitude
    if !valid_coord sanitized[:longitude]
      errors.push "Latitude should be between +/- 90"
    end
    # Check longitude
    if !valid_coord sanitized[:longitude]
      errors.push "Longitude should be between +/- 90"
    end

    # Return 422 response if there are errors
    if errors
      render {
        json: {
          errors: errors,
        }
        status: :unprocessable_entity,
      }
    # Else, render successful response
    else
      render {
        json: closest_drivers(sanitized)
      }
    end
  end

  # Helper methods
  private
  def sanitize_and_normalize_params(params)
    params
    .require(
      :latitude,
      :longitude,
    )
    .permit(
      :latitude,
      :longitude,
      :radius,
      :limit,
    )

    params[:latitude] = params[:latitude].to_f
    params[:longitude] = params[:longitude].to_f
    params[:radius] = params[:radius].to_f or 500
    params[:limit] = params[:limit].to_i or 10

    return params
  end

  # Returns driver objects given query parameters in params
  def closest_drivers(sanitized_params)
    # Important: Parameters must be sanitized because
    # can't use in-built ActiveRecord protections with PostGIS

    Driver
    .where("ST_Distance(
        latlon, 
        'POINT(#{sanitized_params[:latitude]}, #{sanitized_params[:longitude]})'
      ) < #{sanitized_params[:radius]}"
    )
    .limit(sanitized_params[:limit])

  end

  def valid_coord(latlon)
    return latlon.is_a?latlon >= -90 and latlon <= 90
  end
end
