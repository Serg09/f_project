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
      response = HTTParty.post(config.rate_service_url, request_body)
      puts response.inspect
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
      {
        "Name": config.company_name,
        "ShipperNumber": config.account_number,
        "Address": {
          "AddressLine": [
            config.company_address.line_1
          ],
          "City": config.company_address.city,
          "StateProvinceCode": config.company_address.state,
          "PostalCode": config.company_address.postal_code,
          "CountryCode": config.company_address.country_code,
        }
      }
    end

    def ship_to
      {
        "Name": @order.shipping_address.recipient,
        "Address": {
          "AddressLine": [
            @order.shipping_address.line_1,
            @order.shipping_address.line_2
          ].compact,
          "City": @order.shipping_address.city,
          "StateProvinceCode": @order.shipping_address.state,
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
        "Name": origination_company,
        "Address": {
          "AddressLine": [
            origination_company.address.line_1,
            origination_company.address.line_2
          ].compact,
          "City": origination_company.address.city,
          "StateProvinceCode": origination_company.address.state,
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
            "Code": "Lbs",
            "Description": "pounds"
          },
          "Weight": total_weight
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
        "Package": package,
        "ShipmentRatingOptions": {
          "NegotiatedRatesIndicator": ""
        }
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
      }
    end
  end
end
