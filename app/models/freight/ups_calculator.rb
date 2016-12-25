module Freight
  class UpsCalculator < BaseCalculator
    class Configuration
      attr_accessor :username,
        :password,
        :access_key,
        :rate_service_url,
        :company_name,
        :account_number,
        :company_address,
        :origination_company
    end

    class << self
      def config
        @config ||= Configuration.new
      end

      def configure
        yield config
      end
    end

    def initialize(order)
      @order = order
    end

    def rate
      @rate ||= fetch_rate
    end

    private

    def config
      self.class.config
    end

    def fetch_rate
      http_response = HTTParty.post \
        config.rate_service_url,
        body: request_body,
        headers: {
          'Content-Type' => 'application/json',
          'Accept' => 'application/json'
        }
      data = JSON.parse(http_response.body, symbolize_names: true)
      raise_on_error data
      BigDecimal.new data.dig(:RateResponse,
                              :RatedShipment,
                              :RatedPackage,
                              :TotalCharges,
                              :MonetaryValue)
    end

    def ups_security
      {
        "UsernameToken": {
          "Username": config.username,
          "Password": config.password
        },
        "ServiceAccessToken": {
          "AccessLicenseNumber": config.access_key
        }
      }
    end

    def shipper
      raise 'Freight::UpsCalculator configuration is incomplete: company_address is missing' unless config.company_address
      {
        "Address": {
          "PostalCode": config.company_address.postal_code,
          "CountryCode": config.company_address.country_code,
        }
      }
    end

    def ship_to
      {
        "Address": {
          "PostalCode": @order.shipping_address.postal_code,
          "CountryCode": @order.shipping_address.country_code,
        }
      }
    end

    def origination_company
      config.origination_company
    end

    def ship_from
      {
        "Address": {
          "PostalCode": origination_company.address.postal_code,
          "CountryCode": origination_company.address.country_code
        }
      }
    end

    def package
      {
        "PackagingType": {
          "Code": "02",
          "Description": "Rate"
        },
        "Dimensions": {
          "UnitOfMeasurement": {
            "Code": "IN",
            "Description": "inches"
          },
          "Length": "12",
          "Width": "12",
          "Height": "12"
        },
        "PackageWeight": {
          "UnitOfMeasurement": {
            "Code": "LBS",
            "Description": "pounds"
          },
          "Weight": total_weight.to_s
        }
      }
    end

    def shipment
      {
        "Shipper": shipper,
        "ShipTo": ship_to,
        "ShipFrom": ship_from,
        "Service": {
          "Code": "03",
          "Description": "Service Code Description"
        },
        "Package": package
      }
    end

    def rate_request
      {
        "Request": {
          "RequestOption": "Rate",
          "TransactionReference": {
            "CustomerContext": "Cost for shipping order"
          }
        },
        "Shipment": shipment
      }
    end

    def request_body
      {
        "UPSSecurity": ups_security,
        "RateRequest": rate_request
      }.to_json
    end

    # Accepts parsed JSON from the web service and raises
    # an error if the data indicates an error has ocurred
    def raise_on_error(data)
      types = {
        Error: [:Error, :Description],
        Fault: [:Fault, :detail, :Errors, :ErrorDetail, :PrimaryErrorCode, :Description]
      }
      types.each_pair do |k, v|
        if data[k]
          raise "Unable to get the rate from UPS: #{data.dig *v}"
        end
      end
    end
  end
end
