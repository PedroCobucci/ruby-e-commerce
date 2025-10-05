class CartsController < ApplicationController
  ## TODO Escreva a lógica dos carrinhos aqui
    before_action :set_cart

    def create()
        cart_updated = CartService.new(@cart).create(cart_item_params[:product_id], cart_item_params[:quantity])

        render(json: CartSerializer.render(cart_updated, view: :default), status: :ok)
    end

    def show()
        render(json: CartSerializer.render(@cart, view: :default), status: :ok)
    end

    def add_item()
        cart_updated = CartService.new(@cart).add_item(cart_item_params[:product_id], cart_item_params[:quantity])

        render(json: CartSerializer.render(cart_updated, view: :default), status: :ok)
    rescue ActiveRecord::RecordNotFound
        render json: { error: "Product not found on cart." }, status: :not_found
    end

    def remove_item()
        cart_updated = CartService.new(@cart).remove_item(cart_item_params[:product_id])

        render(json: CartSerializer.render(cart_updated, view: :default), status: :ok)
    rescue ActiveRecord::RecordNotFound
        render json: { error: "Product not found on cart." }, status: :not_found
    end

    private

    def set_cart
        @cart = actual_cart
    end

    def cart_item_params
      params.permit(:product_id, :quantity)
    end
end
