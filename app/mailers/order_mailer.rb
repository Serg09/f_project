class OrderMailer < ApplicationMailer
  def purchase_confirmation(order)
    @order = order
    mail to: @order.customer_email, subject: "Order #{@order.confirmation.slice(0, 8)}"
  end
end
