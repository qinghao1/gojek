class DriversController < ApplicationController
  # GET /drivers
  def index
    begin
      errors = []
      sanitized = sanitize_and_normalize_customer_params(params)

      # Check latitude
      if !valid_coord?(sanitized[:latitude])
        errors.push "Latitude should be between +/- 90"
      end
      # Check longitude
      if !valid_coord?(sanitized[:longitude])
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
      # No errors, render successful response
      else
        render({
          json: closest_drivers(sanitized).to_json,
        })
      end

    # Missing latitude/longitude params
    rescue ActionController::ParameterMissing
        render({
          json: {
            errors: ["Missing latitude and/or longitude"],
          },
          status: :unprocessable_entity,
        })
    end
  end

  # PUT /drivers/:id/location
  def location
    begin
      errors = []
      sanitized = sanitize_and_normalize_driver_req(request.raw_post)

      # Check id
      if !valid_id?(params[:id].to_i)
        render(
          json: {},
          status: :not_found,
        )
        return
      end
      # Check latitude
      if !valid_coord?(sanitized["latitude"])
        errors.push "Latitude should be between +/- 90"
      end
      # Check longitude
      if !valid_coord?(sanitized["longitude"])
        errors.push "Longitude should be between +/- 90"
      end
      # Check accuracy
      if !valid_accuracy?(sanitized["accuracy"])
        errors.push "Accuracy should be between 0 and 1"
      end

      # Return 422 response if there are errors
      if !errors.empty?
        render({
          json: {
            errors: errors,
          },
          status: :unprocessable_entity,
        })
      # No errors, continue
      else
        # Create/update driver record
        driver = Driver.find_by_id(params[:id])
        if driver
          driver.lonlat = 
            "POINT(#{sanitized["longitude"]}"\
            " #{sanitized["latitude"]})"
          driver.accuracy = sanitized["accuracy"]
        else
          driver = Driver.new({
            id: params[:id],
            lonlat: "POINT(#{sanitized["longitude"]}"\
                    " #{sanitized["latitude"]})",
            accuracy: sanitized["accuracy"],
          })
        end

        # Save driver record and render either success or 422
        begin
          driver.save!
          render({
            json: {},
          })
        rescue ActiveRecord::RecordInvalid
          render({
            json: {
              errors: driver.errors.messages,
            },
            status: :unprocessable_entity,
          })
          return
        end
      end

    # Missing latitude/longitude params
    rescue ActionController::ParameterMissing
        render({
          json: {
            errors: ["Missing latitude and/or longitude"],
          },
          status: :unprocessable_entity,
        })
        return
    end
  end

  # Helper methods
  private

  # Given params hash, sanitizes it and sets defaults
  def sanitize_and_normalize_customer_params(params)
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

    # Check that latitude is a decimal number
    if DECIMAL_REGEX =~ params[:latitude]
      params[:latitude] = params[:latitude].to_f
    else
      params[:latitude] = nil
    end

    # Check that longitude is a decimal number
    if DECIMAL_REGEX =~ params[:longitude]
      params[:longitude] = params[:longitude].to_f
    else
      params[:longitude] = nil
    end

    # Check that radius is a decimal number if it exists
    # Else, set to 500 default
    if params[:radius] and DECIMAL_REGEX =~ params[:radius]
      params[:radius] = params[:radius].to_f 
    else
      params[:radius] = 500
    end

    # Check that limit is a decimal number if it exists
    # Else, set to 10 default
    if params[:limit] and DECIMAL_REGEX =~ params[:limit]
      params[:limit] = params[:limit].to_f 
    else
      params[:limit] = 10
    end

    return params
  end

  # Given req string, returns sanitized request as a hash
  def sanitize_and_normalize_driver_req(req)
    begin
      req = JSON.parse(req)
    # Return dummy request if JSON is wonky
    rescue JSON::ParserError
      return {
        "latitude" => nil,
        "longitude" => nil,
        "accuracy" => 1,
      }
    end

    if !req["latitude"].is_a? Numeric
      req["latitude"] = nil
    end
    if !req["longitude"].is_a? Numeric
      req["longitude"] = nil
    end
    req["accuracy"] ||= 1

    return req
  end

  # Returns driver objects given query parameters
  # Important: Parameters must be sanitized because
  # of string interpolation. Unfortunately PostGIS demands this
  def closest_drivers(sanitized_params)
    # Query to find nearest $limit drivers
    nearest_k_drivers = Driver
    .select(
      "ST_Distance("\
      " lonlat,"\
      " 'POINT(#{sanitized_params[:longitude]} #{sanitized_params[:latitude]})'"\
      ") AS distance",
      "id",
      "ST_X(lonlat::geometry) AS longitude",
      "ST_Y(lonlat::geometry) AS latitude"
    )
    .order( # Order by spatial distance; this is optimized by PostGIS
      "lonlat"\
      " <-> "\
      "'POINT(#{sanitized_params[:longitude]} #{sanitized_params[:latitude]})'"
    )
    .limit(sanitized_params[:limit])
    .to_sql

    # Modify query to filter to those within $radius
    nearest_k_drivers_within_radius = 
    "SELECT * FROM (#{nearest_k_drivers}) x "\
    "WHERE distance < #{sanitized_params[:radius]}"

    # Execute query
    ActiveRecord::Base.connection.execute(nearest_k_drivers_within_radius)
  end

  def valid_coord?(lonlat)
    return (lonlat and (lonlat >= -90 and lonlat <= 90))
  end

  def valid_id?(id)
    return (id >= 1 and id <= 50000)
  end

  def valid_accuracy?(acc)
    return (acc >= 0 and acc <= 1)
  end

  DECIMAL_REGEX = /\d+(\.\d+)?/.freeze
end
