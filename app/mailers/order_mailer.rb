class OrderMailer < ApplicationMailer
  def purchase_confirmation(order)
    @order = order
    mail to: @order.customer_email,
         from: "#{@order.client.name} <noreply@crowdscribed.com>",
         subject: "Order #{@order.abbreviated_confirmation}"
  end
end
