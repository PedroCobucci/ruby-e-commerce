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
FactoryBot.define do
    factory :cart_item do
        quantity { Faker::Number.between(from: 1, to: 10) }

        association :cart, factory: :shopping_cart
        association :product

        after(:create) do |cart_item|
            cart_item.cart.recalculate_total_price!
        end
    end
end
