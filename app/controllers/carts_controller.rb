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
      if line_item_reserved?(line_item)
        @order.contents.remove(line_item.variant, line_item.quantity)
        flash[:notice] = "Un ou plusieurs créneaux horaires réservés ont été retirés de votre panier."
      end
    end
  
    redirect_to edit_cart_path if flash[:notice].present?
  end
  
  
  def line_item_reserved?(line_item)
    # Exemple fictif basé sur des métadonnées stockées dans le line_item
    # Cet exemple suppose que vous avez des champs ou des métadonnées indiquant la réservation
    date = line_item.metadata['reservation_date']
    time_slot = line_item.metadata['time_slot']
    
    # Ici, vous devriez implémenter votre logique pour vérifier si ce créneau est effectivement réservé.
    # Cette vérification pourrait dépendre de la manière dont votre application gère les réservations.
    # Par exemple, vérifier s'il y a un conflit de réservation dans les commandes complétées.
    
    # Exemple fictif de vérification :
    # Supposons que vous avez une méthode qui peut vérifier les conflits basée sur la date et le créneau horaire.
    check_reservation_conflict(date, time_slot)
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
