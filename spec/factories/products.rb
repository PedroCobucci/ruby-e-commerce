# == Schema Information
#
# Table name: products
#
#  id         :bigint           not null, primary key
#  name       :string
#  price      :decimal(17, 2)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
FactoryBot.define do
 
  factory :product, class: 'Product' do

    name { Faker::Commerce.product_name }
    price { Faker::Commerce.price(range: 5.0..200.0).to_d }

  end
end
