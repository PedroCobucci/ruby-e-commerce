# == Schema Information
#
# Table name: carts
#
#  id          :bigint           not null, primary key
#  status      :string           default("active"), not null
#  total_price :decimal(17, 2)   default(0.0)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_carts_on_status  (status)
#
class CartSerializer < Blueprinter::Base
    view :default do
        identifier :id

        association :cart_items, name: :products, blueprint: CartItemSerializer, view: :products
        fields :total_price
    end
end
