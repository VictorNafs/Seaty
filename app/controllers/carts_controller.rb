# frozen_string_literal: true

class CartsController < StoreController
  helper 'spree/products', 'orders'

  respond_to :html

  before_action :store_guest_token
  before_action :ensure_logged_in, only: [:edit]
  before_action :assign_order, only: :update
  before_action :remove_reserved_time_slots, only: [:edit, :update]
  around_action :lock_order, only: :update

  # Shows the current incomplete order from the session
  def edit
    @order = current_order(build_order_if_necessary: true)
    authorize! :edit, @order, cookies.signed[:guest_token]
    if params[:id] && @order.number != params[:id]
      flash[:error] = t('spree.cannot_edit_orders')
      redirect_to edit_cart_path
    end
  end
  
  private
  
  def remove_reserved_time_slots
    @order = current_order
    return unless @order
  
    @order.line_items.each do |line_item|
      # Vérifiez si le créneau horaire associé au line_item est réservé.
      if time_slot_reserved?(line_item)
        @order.contents.remove(line_item.variant, line_item.quantity)
        flash[:alert] = "Certains créneaux horaires ont été retirés de votre panier car ils ne sont plus disponibles."
      end
    end
  end

  def time_slot_reserved?(line_item)
    # Exemple de vérification basée sur une hypothétique relation ou un champ indiquant le statut de réservation.
    # Vous devrez adapter cette logique en fonction de la manière dont votre application suit les créneaux réservés.
    
    # Si vous avez par exemple une table ou un champ indiquant les réservations, vous pourriez faire quelque chose comme :
    Reservation.exists?(product_id: line_item.variant.product_id, start_time: line_item.date.beginning_of_day..line_item.date.end_of_day)
  end
  
  

  def update
    authorize! :update, @order, cookies.signed[:guest_token]
    if @order.contents.update_cart(order_params)
      @order.next if params.key?(:checkout) && @order.cart?

      respond_with(@order) do |format|
        format.html do
          if params.key?(:checkout)
            redirect_to checkout_state_path(@order.checkout_steps.first)
          else
            redirect_to edit_cart_path
          end
        end
      end
    else
      respond_with(@order)
    end
  end

  def empty
    if @order = current_order
      authorize! :update, @order, cookies.signed[:guest_token]
      @order.empty!
    end

    redirect_to edit_cart_path
  end

  private

  def ensure_logged_in
    unless spree_current_user
      redirect_to login_path, notice: 'Veuillez vous connecter pour accéder à votre panier.'
    end
  end

  def accurate_title
    t('spree.shopping_cart')
  end

  def store_guest_token
    cookies.permanent.signed[:guest_token] = params[:token] if params[:token]
  end

  def order_params
    if params[:order]
      params[:order].permit(*permitted_order_attributes)
    else
      {}
    end
  end

  def assign_order
    @order = current_order
    unless @order
      flash[:error] = t('spree.order_not_found')
      redirect_to(root_path) && return
    end
  end
end
