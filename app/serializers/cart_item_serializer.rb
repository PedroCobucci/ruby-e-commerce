# == Schema Information
#
# Table name: cart_items
#
#  id         :bigint           not null, primary key
#  quantity   :integer          default(0), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  cart_id    :bigint           not null
#  product_id :bigint           not null
#
# Indexes
#
#  index_cart_items_on_cart_id                 (cart_id)
#  index_cart_items_on_cart_id_and_product_id  (cart_id,product_id) UNIQUE
#  index_cart_items_on_product_id              (product_id)
#
# Foreign Keys
#
#  fk_rails_...  (cart_id => carts.id)
#  fk_rails_...  (product_id => products.id)
#
class CartItemSerializer < Blueprinter::Base
    view :products do
        identifier :id do |cart_item|
            cart_item.product.id
        end

        field :name do |cart_item|
            cart_item.product.name
        end

        field :unit_price do |cart_item|
            cart_item.product.price
        end

        field :quantity

        field :total_price
    end
end
