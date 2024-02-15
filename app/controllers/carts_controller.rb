# frozen_string_literal: true

class CartsController < StoreController
  helper 'spree/products', 'orders'

  respond_to :html

  before_action :store_guest_token
  before_action :ensure_logged_in, only: [:edit]
  before_action :assign_order, only: :update
  # note: do not lock the #edit action because that's where we redirect when we fail to acquire a lock
  around_action :lock_order, only: :update

  # Shows the current incomplete order from the session
  def edit
  @order = current_order(build_order_if_necessary: true)
  authorize! :edit, @order, cookies.signed[:guest_token]
    
  @order.line_items.each do |line_item|
    # Supposons que line_item a des attributs :date et :time_slot
    if time_slot_no_longer_available?(line_item.date, line_item.time_slot)
      @order.contents.remove(line_item.variant, line_item.quantity)
      flash[:notice] = "Un ou plusieurs créneaux horaires ont été retirés de votre panier."
    end
  end

  redirect_to edit_cart_path if flash[:notice].present?
end

private

def time_slot_no_longer_available?(date, time_slot)
  # Implémentez la logique pour déterminer si le créneau est toujours disponible
  # Cela pourrait impliquer de vérifier si le créneau est inclus dans une commande complétée
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
