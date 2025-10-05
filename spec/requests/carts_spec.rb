require 'rails_helper'

RSpec.describe "/carts", type: :request do
    describe "POST /cart" do
        context 'when the cart starts empty' do
            it 'creates a new cart item' do
                cart = create(:shopping_cart)
                product = create(:product)

                post '/cart', params: { product_id: product.id, quantity: 1 }, as: :json

                cart.reload
                expect(cart.cart_items.count).to(eq(1))
                expect(cart.cart_items.first.product_id).to(eq(product.id))
                expect(cart.cart_items.first.quantity).to(eq(1))
            end

            it 'creates the same cart item twice' do
                cart = create(:shopping_cart)
                product = create(:product)

                post '/cart', params: { product_id: product.id, quantity: 1 }, as: :json
                post '/cart', params: { product_id: product.id, quantity: 3 }, as: :json

                cart.reload
                expect(cart.cart_items.count).to(eq(1))
                expect(cart.cart_items.first.product_id).to(eq(product.id))
                expect(cart.cart_items.first.quantity).to(eq(4))
            end

            it 'Creates two different itens in when cart does not exists' do
                product1 = create(:product)
                product2 = create(:product)

                post '/cart', params: { product_id: product1.id, quantity: 1 }, as: :json
                post '/cart', params: { product_id: product2.id, quantity: 3 }, as: :json

                cart = Cart.first
                expect(cart.cart_items.count).to(eq(2))
                expect(cart.cart_items.find_by(product_id: product1.id).quantity).to(eq(1))
                expect(cart.cart_items.find_by(product_id: product2.id).quantity).to(eq(3))
            end

            it 'Creates three different itens when cart does not exists and check the body response' do
                product1 = create(:product)
                product2 = create(:product)
                product3 = create(:product)

                post '/cart', params: { product_id: product1.id, quantity: 1 }, as: :json
                post '/cart', params: { product_id: product2.id, quantity: 3 }, as: :json
                post '/cart', params: { product_id: product3.id, quantity: 5 }, as: :json

                cart = Cart.first
                cart_total_price = (product1.price * 1) + (product2.price * 3) + (product3.price * 5)

                expected_response = {
                    "id" => cart.id,
                    "products" => [
                        {"id" => product1.id, "name" => product1.name, "quantity" => 1, "unit_price" => product1.price.to_s, "total_price" => (product1.price * 1).to_s},
                        {"id" => product2.id, "name" => product2.name, "quantity" => 3, "unit_price" => product2.price.to_s, "total_price" => (product2.price * 3).to_s},
                        {"id" => product3.id, "name" => product3.name, "quantity" => 5, "unit_price" => product3.price.to_s, "total_price" => (product3.price * 5).to_s}
                    ],
                    "total_price" => cart_total_price.to_s
                }

                expect(cart.cart_items.count).to(eq(3))
                expect(cart.cart_items.find_by(product_id: product1.id).quantity).to(eq(1))
                expect(cart.cart_items.find_by(product_id: product2.id).quantity).to(eq(3))
                expect(cart.cart_items.find_by(product_id: product3.id).quantity).to(eq(5))
                expect(JSON.parse(response.body)).to(match(expected_response))
            end
        end
    end

    describe "GET /cart" do
        context 'when the cart has items' do
            it 'returns the cart with its items' do
                cart = create(:shopping_cart)
                product1 = create(:product)
                product2 = create(:product)
                cart_item1 = create(:cart_item, cart: cart, product: product1, quantity: 2)
                cart_item2 = create(:cart_item, cart: cart, product: product2, quantity: 1)

                get '/cart', as: :json

                cart_total_price = (product1.price * 2) + (product2.price * 1)

                expected_response = {
                    "id" => cart.id,
                    "products" => [
                        {"id" => product1.id, "name" => product1.name, "quantity" => 2, "unit_price" => product1.price.to_s, "total_price" => (product1.price * 2).to_s},
                        {"id" => product2.id, "name" => product2.name, "quantity" => 1, "unit_price" => product2.price.to_s, "total_price" => (product2.price * 1).to_s}
                    ],
                    "total_price" => cart_total_price.to_s
                }

                expect(response).to have_http_status(:ok)
                expect(JSON.parse(response.body)).to(match(expected_response))
            end
        end

        context 'when the cart is empty' do
            it 'returns an empty cart' do
                create(:shopping_cart)

                get '/cart', as: :json

                expected_response = {
                    "id" => Cart.first.id,
                    "products" => [],
                    "total_price" => "0.0"
                }

                expect(response).to have_http_status(:ok)
                expect(JSON.parse(response.body)).to(match(expected_response))
            end
        end
    end

    describe "POST /cart/add_item" do
        context 'when the product does not exists in the cart' do
            it 'returns a not found error' do
                cart = create(:shopping_cart)
                product = create(:product)
                cart_item = create(:cart_item, cart: cart, product: product, quantity: 2)
                
                post '/cart/add_item', params: { product_id: product.id+25, quantity: 1 }, as: :json

                expect(response).to(have_http_status(:not_found))
                expect(JSON.parse(response.body)).to(eq({ "error" => "Product not found on cart." }))
            end
        end
    end

    describe "DELETE  /cart/:product_id" do
        context 'when removing an item from a cart with several items' do
            it 'removes the specified item from the cart and returns the updated cart' do
                cart = create(:shopping_cart)
                product1 = create(:product)
                product2 = create(:product)
                cart_item1 = create(:cart_item, cart: cart, product: product1, quantity: 1)
                cart_item2 = create(:cart_item, cart: cart, product: product2, quantity: 1)

                delete "/cart/#{product1.id}"

                cart.reload

                expected_response = {
                    "id" => cart.id,
                    "products" => [
                        {"id" => product2.id, "name" => product2.name, "quantity" => 1, "unit_price" => product2.price.to_s, "total_price" => (product2.price * 1).to_s}
                    ],
                    "total_price" => (product2.price * 1).to_s
                }

                expect(response).to(have_http_status(:ok))
                expect(cart.cart_items.count).to(eq(1))
                expect(cart.cart_items.first.product_id).to(eq(product2.id))
                expect(JSON.parse(response.body)).to(match(expected_response))
            end
        end

        context 'when removing the last item from the cart' do
            it 'removes the item and returns an empty cart' do
                cart = create(:shopping_cart)
                product = create(:product)
                cart_item = create(:cart_item, cart: cart, product: product, quantity: 1)

                delete "/cart/#{product.id}"

                cart.reload

                expected_response = {
                    "id" => cart.id,
                    "products" => [],
                    "total_price" => "0.0"
                }

                expect(response).to(have_http_status(:ok))
                expect(cart.cart_items.count).to(eq(0))
                expect(JSON.parse(response.body)).to(match(expected_response))
            end
        end

        context 'when the product does not exists in the cart' do
              it 'returns a not found error' do
                cart = create(:shopping_cart)
                product = create(:product)
                cart_item = create(:cart_item, cart: cart, product: product, quantity: 1)


                delete "/cart/#{product.id+25}"

                expect(response).to(have_http_status(:not_found))
                expect(JSON.parse(response.body)).to(eq({ "error" => "Product not found on cart." }))
            end
        end
    end

    describe "POST /add_item" do
        let(:cart) { Cart.create }
        let(:product) { Product.create(name: "Test Product", price: 10.0) }
        let!(:cart_item) { CartItem.create(cart: cart, product: product, quantity: 1) }

        context 'when the product already is in the cart' do
        subject do
            post '/cart/add_item', params: { product_id: product.id, quantity: 1 }, as: :json
            post '/cart/add_item', params: { product_id: product.id, quantity: 1 }, as: :json
        end

        it 'updates the quantity of the existing item in the cart' do
            expect { subject }.to(change { cart_item.reload.quantity }.by(2))
        end
        end
    end
end
