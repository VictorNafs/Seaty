# frozen_string_literal: true

class OrdersController < StoreController
  helper 'spree/products', 'orders'

  respond_to :html

  before_action :store_guest_token

  def show
    @order = Spree::Order.find_by!(number: params[:id])
    authorize! :show, @order, cookies.signed[:guest_token]
  end

  def current_order(create_order_if_necessary: false)
    return @current_order if @current_order
  
    if cookies.signed[:order_id]
      @current_order = Spree::Order.find_by(id: cookies.signed[:order_id])
    elsif create_order_if_necessary
      @current_order = Spree::Order.create!(order_params)
      cookies.permanent.signed[:order_id] = @current_order.id
    end
  
    @current_order
  end

  def populate
    order = current_order(create_order_if_necessary: true)
    product_timeslots = params[:product_timeslots]
    success = true
    last_product = nil
  
    product_timeslots.each do |product_timeslot|
      product_id, time_slot = product_timeslot.split(',')
      product = Spree::Product.find(product_id)
      last_product = product
      variant = product.master
      date = params[:selected_date].to_date
  
      # Vérifier si le LineItem avec la même date et le même créneau horaire existe déjà
      existing_line_item = order.line_items.find_by(date: date, time_slot: time_slot, variant: variant)
      if existing_line_item
        # Si l'élément existe déjà, ne faites rien et passez au suivant
        next
      end
  
      # Si l'élément n'existe pas, créez un nouvel élément
      line_item = Spree::LineItem.new(
        order: order,
        variant: variant,
        quantity: 1,
        date: date,
        time_slot: time_slot
      )
  
      # Ajouter l'article à la commande
      if line_item.save
        order.line_items << line_item
        order.recalculate
      else
        success = false
      end
    end
  
    if success
      flash[:success] = I18n.t(:successfully_added_to_your_cart)
      redirect_to main_app.product_path(last_product)
    else
      flash[:error] = I18n.t(:not_all_items_added_to_cart)
      redirect_to main_app.product_path(last_product)
    end
  end
  
  
  

  private

  def store_guest_token
    cookies.permanent.signed[:guest_token] = params[:token] if params[:token]
  end

  def order_params
    {
      user_id: spree_current_user&.id,
      store_id: current_store.id,
      currency: current_currency,
      guest_token: cookies.signed[:guest_token]
    }
  end

  def current_currency
    "USD" # Remplacez par la devise souhaitée
  end
end
