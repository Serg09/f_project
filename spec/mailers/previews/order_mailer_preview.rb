# Preview all emails at http://localhost:3030/rails/mailers/order_mailer
class OrderMailerPreview < ActionMailer::Preview
  def purchase_confirmation
    order = Order.first || FactoryGirl.create(:submitted_order)
    order.confirmation ||= Faker::Number.hexadecimal(32)
    OrderMailer.purchase_confirmation order
  end
end
