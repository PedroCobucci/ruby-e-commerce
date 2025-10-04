# == Schema Information
#
# Table name: carts
#
#  id          :bigint           not null, primary key
#  status      :string           default("active"), not null
#  total_price :decimal(17, 2)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_carts_on_status  (status)
#
FactoryBot.define do
 
  factory :shopping_cart, class: 'Cart' do

    status { 'active' }
    total_price { 0.0 }
    transient do
      last_interaction_at { nil }
    end
    updated_at { last_interaction_at || Time.current }
    created_at { updated_at }

  end
end
