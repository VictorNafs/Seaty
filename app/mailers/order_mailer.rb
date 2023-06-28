class OrderMailer < Spree::BaseMailer
    def order_confirmation(order, store)
      @order = order
      @store = store
      mail to: order.email, from: from_address(@store), subject: "#{@store.name} Confirmation de commande ##{order.number}"
    end
  end
  