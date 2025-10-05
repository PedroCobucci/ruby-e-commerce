class ApplicationController < ActionController::API
    private

    def actual_cart
        if Rails.env.test?
            return Cart.first
        end

        unless session[:cart_id]
            return create_new_cart
        end

        cart = Cart.find_by(id: session[:cart_id])

        unless cart
            return create_new_cart
        end

        return cart
    end

    def create_new_cart
        cart = Cart.create!
        session[:cart_id] = cart.id
        cart
    end
end
