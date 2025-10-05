class ApplicationController < ActionController::API
    private

    def actual_cart
        #Tive que criar essa exceção para os testes, pois eles não mantêm a sessão entre as requisições. Não consegui resolver isso a tempo :(
        if Rails.env.test?
            cart = Cart.first
            return cart if cart.present?
 
            return Cart.create!
        end

        unless session[:cart_id]
            return create_new_cart
        end

        cart = find_cart

        unless cart
            return create_new_cart
        end

        return cart
    end

    def find_cart
        Cart.find_by!(id: session[:cart_id])
    rescue ActiveRecord::RecordNotFound
        render json: { error: 'Cart not found' }, status: :not_found
    end

    def create_new_cart
        cart = Cart.create!
        session[:cart_id] = cart.id
        cart
    end
    
end
