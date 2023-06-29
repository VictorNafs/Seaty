# lib/tasks/delete_product_stocks.rake

namespace :product_stocks do
  desc 'Delete product stocks for the next 30 days'
  task :delete, [:product_id] => :environment do |t, args|
    products = args[:product_id] ? Spree::Product.where(id: args[:product_id]) : Spree::Product.all

    products.find_each do |product|
      # Assume that each product has only one variant (the master variant)
      variant = product.master
      
      variant.stock_items.each do |stock_item|
        stock_item.stock_movements.where("date >= ? AND date < ?", Date.today, Date.today + 30).delete_all
      end
    end
  end
end
