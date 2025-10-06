# == Schema Information
#
# Table name: carts
#
#  id          :bigint           not null, primary key
#  status      :string           default("active"), not null
#  total_price :decimal(17, 2)   default(0.0)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_carts_on_status  (status)
#
class Cart < ApplicationRecord
    validates_numericality_of :total_price, greater_than_or_equal_to: 0
    after_commit :flush_cache
    

    # TODO: lógica para marcar o carrinho como abandonado e remover se abandonado

    has_many :cart_items, dependent: :destroy
    has_many :products, through: :cart_items

    enum status: { active: 'active', abandoned: 'abandoned' }

    scope :abandonable, -> { where(status: :active).where('updated_at < ?', 3.hours.ago) }
    scope :purgeable, -> { where(status: :abandoned).where('updated_at < ?', 7.days.ago) }

    #Como vou usar o "touch" não vou precisar lidar com o last_interaction_at manualmente, mas ainda preciso disso para os testes
    alias_attribute :last_interaction_at, :updated_at


    def mark_as_abandoned
        if self.last_interaction_at < 3.hours.ago
            self.update_column(:status, 'abandoned')
        end
    end

    def remove_if_abandoned
        if self.abandoned? && self.last_interaction_at <= 7.days.ago
            self.destroy!
        end
    end

    def recalculate_total_price!
        new_total = self.cart_items.includes(:product).sum do |item|
            item.product.price * item.quantity
        end

        self.update!(total_price: new_total || 0.0)
    end

    def flush_cache
        Rails.cache.delete("cart:#{self.id}")
    end
end
