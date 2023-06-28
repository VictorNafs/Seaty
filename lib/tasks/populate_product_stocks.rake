require 'date'

namespace :product_stocks do
  desc 'Populate product stocks for the next 30 days'
  task populate: :environment do
    Spree::Product.find_each do |product|
      # Assume that each product has only one variant (the master variant)
      variant = product.master

      (1..30).each do |day_offset|
        date = Date.today + day_offset
        stock_location = Spree::StockLocation.first

        ["8h - 13h", "14h - 20h"].each do |time_slot|
          # Check if there is already a stock item for this date and time slot
          existing_stock_item = variant.stock_items.joins(:stock_movements)
                                                   .where('spree_stock_movements.date = ? AND spree_stock_movements.time_slot = ?', date, time_slot)
                                                   .first

          # Create stock item for this date and time slot if it does not exist yet
          if existing_stock_item.nil?
            stock_item = stock_location.stock_items.find_or_create_by(variant: variant)
            stock_movement = stock_item.stock_movements.create!(
              quantity: 1,
              date: date,
              time_slot: time_slot,
              action: 'restock'
            )
          end
        end
      end
    end
  end
end
