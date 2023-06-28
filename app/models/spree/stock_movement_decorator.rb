module Spree
    module StockMovementDecorator
      def self.prepended(base)
        base.validates :time_slot, presence: false
      end
    end
  end
  
  Spree::StockMovement.prepend Spree::StockMovementDecorator
  