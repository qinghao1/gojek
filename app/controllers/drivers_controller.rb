class DriversController < ApplicationController
  def index
    begin
      # Check for errors:
      errors = []
      sanitized = sanitize_and_normalize_customer_params(params)

      # Check latitude
      if !valid_coord(sanitized[:latitude])
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

  def location
    begin
      # Check for errors:
      errors = []
      sanitized = sanitize_and_normalize_driver_req(request.raw_post)

      # Check id
      if !valid_id(params[:id].to_i)
        render(
          json: {},
          status: :not_found,
        )
      end
      # Check latitude
      if !valid_coord(sanitized["latitude"])
        errors.push "Latitude should be between +/- 90"
      end
      # Check longitude
      if !valid_coord(sanitized["longitude"])
        errors.push "Longitude should be between +/- 90"
      end
      # Check accuracy
      if !valid_accuracy(sanitized["accuracy"])
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
      # Else, render successful response
      else
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
        end
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

    params[:latitude] = params[:latitude].to_f
    params[:longitude] = params[:longitude].to_f
    params[:radius] = params[:radius] ? params[:radius].to_f : 500
    params[:limit] = params[:limit] ? params[:limit].to_f : 10

    return params
  end

  def sanitize_and_normalize_driver_req(req)
    req = JSON.parse(req)
    if req["latitude"].is_a? String
      req["latitude"] = nil
    end
    if req["longitude"].is_a? String
      req["longitude"] = nil
    end
    req["accuracy"] ||= 1

    return req
  end

  # Returns driver objects given query parameters in params
  def closest_drivers(sanitized_params)
    # Important: Parameters must be sanitized because
    # can't use in-built ActiveRecord protections with PostGIS

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
    .where(
      "ST_Distance(
        lonlat, 
        'POINT(#{sanitized_params[:longitude]} #{sanitized_params[:latitude]})'
      ) < #{sanitized_params[:radius]}"
    )
    .order("distance")
    .limit(sanitized_params[:limit])
  end

  def valid_coord(lonlat)
    return (lonlat and (lonlat >= -90 and lonlat <= 90))
  end

  def valid_id(id)
    return (id >= 1 and id <= 50000)
  end

  def valid_accuracy(acc)
    return (acc >= 0 and acc <= 1)
  end
end
