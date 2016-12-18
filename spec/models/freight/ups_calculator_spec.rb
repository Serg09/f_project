require 'rails_helper'

describe Freight::UpsCalculator do
  let (:order) { FactoryGirl.create :order }

  it 'can be created with an order' do
    calculator = Freight::UpsCalculator.new(order)
    expect(calculator).not_to be_nil
  end

  describe '#rate' do
    let (:calculator) { Freight::UpsCalculator.new(order) }
    let (:http_response) do
      <<-JSON
      {
        "RateResponse": {
          "Response": {
            "ResponseStatus": {
              "Code": "1",
              "Description": "Success"
            },
            "Alert": {
              "Code": "110971",
              "Description": "Yourinvoicemayvaryfrom...."
            },
            "TransactionReference": {
              "CustomerContext": "YourCustomerContext"
            }
          },
          "RatedShipment": {
            "Service": {
              "Code": "03",
              "Description": ""
            },
            "RatedShipmentAlert": {
              "Code": "110971",
              "Description": "Yourinvoicemayvary...."
            },
            "BillingWeight": {
              "UnitOfMeasurement": {
                "Code": "LBS",
                "Description": "Pounds"
              },
              "Weight": "1.0"
            },
            "TransportationCharges": {
              "CurrencyCode": "USD",
              "MonetaryValue": "8.60"
            },
            "ServiceOptionsCharges": {
              "CurrencyCode": "USD",
              "MonetaryValue": "0.00"
            },
            "TotalCharges": {
              "CurrencyCode": "USD",
              "MonetaryValue": "8.60"
            },
            "NegotiatedRateCharges": {
              "TotalCharge": {
                "CurrencyCode": "USD",
                "MonetaryValue": "7.92"
              }
            },
            "RatedPackage": {
              "TransportationCharges": {
                "CurrencyCode": "USD",
                "MonetaryValue": "8.60"
              },
              "ServiceOptionsCharges": {
                "CurrencyCode": "USD",
                  "MonetaryValue": "0.00"
              },
              "TotalCharges": {
                "CurrencyCode": "USD",
                "MonetaryValue": "8.60"
              },
              "Weight": "1.0",
              "BillingWeight": {
                "UnitOfMeasurement": {
                  "Code": "LBS",
                  "Description": "Pounds"
                },
                "Weight": "1.0"
              }
            }
          }
        }
      }
      JSON
    end
    before do
      expect(HTTParty).to receive(:post).
        and_return(http_response)
    end

    it 'returns the value provided by the service' do
      expect(calculator.rate).to eq 8.6
    end
  end
end
