require 'rails_helper'

RSpec.describe CartItem, type: :model do

    context 'when validating' do
        it 'invalidates negative quantity' do
            cart_item = build(:cart_item, quantity: -1)
            expect(cart_item.valid?).to(be_falsey)
            expect(cart_item.errors[:quantity]).to include("must be greater than 0")
        end

        it 'invalidates zero quantity' do
            cart_item = build(:cart_item, quantity: 0)
            expect(cart_item.valid?).to(be_falsey)
            expect(cart_item.errors[:quantity]).to include("must be greater than 0")
        end 

        it 'validates positive quantity' do
            cart_item = build(:cart_item, quantity: 1)
            expect(cart_item.valid?).to(be_truthy)
        end

        it 'validates total_price calculation' do
            product = build(:product, price: 50)
            cart_item = build(:cart_item, product: product, quantity: 2)
            expect(cart_item.total_price).to eq(100)
        end

        it 'validates invalid total_price calculation' do
            product = build(:product, price: 30)
            cart_item = build(:cart_item, product: product, quantity: -3)

            expect(cart_item.valid?).to(be_falsey)
            expect(cart_item.errors[:quantity]).to include("must be greater than 0")
            expect(cart_item.errors[:total_price]).to include("must be greater than or equal to 0")
        end
    end
end
