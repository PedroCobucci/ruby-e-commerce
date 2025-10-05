RSpec.describe CartService, type: :service do
    let(:cart) { create(:shopping_cart) }

    subject(:cart_service) { described_class.new(cart) }

    describe 'full user journey simulation' do
        it 'simulates a random user session of adding, updating, and removing items' do
            product_a = create(:product, price: 50.00)
            product_b = create(:product, price: 10.50)
            product_c = create(:product, price: 100.00)

            #Primeiro usuario adiciona 2 produtos de 50 reais
            cart_service.create(product_a.id, 2)
            cart.reload
            expect(cart.total_price).to(eq(100.00))
            expect(cart.cart_items.count).to(eq(1))

            #Depois adiciona 5 produtos de 10,50
            cart_service.create(product_b.id, 5)
            cart.reload
            expect(cart.total_price).to(eq(152.50)) # 100 + (5 * 10,50)
            expect(cart.cart_items.count).to(eq(2))

            #Depois adiciona 3 produtos de 50 reais
            cart_service.add_item(product_a.id, 3)
            cart.reload
            expect(cart.cart_items.find_by(product: product_a).quantity).to(eq(5))
            expect(cart.total_price).to(eq(302.50)) # 100 + (5 * 10,50) + (3 * 50) === 2*a + 5*b + 3*a


            # Depois remove 5 produtos de 10,50 (b)
            cart_service.remove_item(product_b.id)
            cart.reload
            expect(cart.total_price).to(eq(250.00)) # sobram só os 5 produtos A === 50 * 5
            expect(cart.cart_items.count).to(eq(1))

            # Depois adiciona 1 novo produto de 100 reais
            cart_service.create(product_c.id, 1)
            cart.reload
            expect(cart.total_price).to(eq(350.00)) # 250.00 + 100.00 === 5*a + 1*c
            expect(cart.cart_items.count).to(eq(2))

            # Depos remove todos os produtos
            cart_service.remove_item(product_a.id)
            cart_service.remove_item(product_c.id)
            cart.reload
            expect(cart.total_price).to(eq(0.00))
            expect(cart.cart_items).to(be_empty)
        end
    end
end