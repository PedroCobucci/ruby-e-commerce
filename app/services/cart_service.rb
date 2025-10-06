class CartService
    def initialize(cart)
        @cart = cart
    end

    def create(product_id, quantity)
        @cart.transaction do
            item = @cart.cart_items.find_or_initialize_by(product_id: product_id)
            item.quantity += quantity.to_i

            item.save!

            @cart.recalculate_total_price!
        end

        @cart.reload
    end

    def add_item(product_id, quantity)
        @cart.transaction do
            item = @cart.cart_items.find_by!(product_id: product_id)
            
            item.quantity += quantity.to_i

            item.save!

            @cart.recalculate_total_price!
        end
        @cart.reload
    end

    def remove_item(product_id)
        @cart.transaction do
            item = @cart.cart_items.find_by!(product_id: product_id)

            item.destroy!

            @cart.recalculate_total_price!
        end
        @cart.reload
    end
end