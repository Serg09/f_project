module PaymentsHelper
  SUCCESS_STATUSES = %(approved completed)
  def payment_provider_response(status, options = {})
    transaction = double 'transation', status: status,
                                       id: options[:id] || Faker::Number.number(8)
    attributes = {success?: SUCCESS_STATUSES.include?(status),
                  transaction: transaction,
                  to_yaml: File.read(Rails.root.join('spec', 'fixtures', 'files', 'payment_response.yml'))}
    attributes[:errors] = errors if options[:errors]
    result = double 'response', attributes
  end
end
