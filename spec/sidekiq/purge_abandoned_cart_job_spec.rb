require 'rails_helper'
RSpec.describe PurgeAbandonedCartsJob, type: :job do
    subject(:run_job) { described_class.new.perform }

    describe "#perform" do
        context 'when there are no eligible purgeable carts (all active carts or less than 7 days old)' do
            it 'does not change the status of any cart' do
                recent_cart = create(:shopping_cart, last_interaction_at: 1.hour.ago, status: 'active')
                recent_cart_2 = create(:shopping_cart, last_interaction_at: 2.hours.ago, status: 'active')
                recent_abandoned_cart = create(:shopping_cart, last_interaction_at: 10.hours.ago, status: 'abandoned')
                recent_abandoned_cart_2 = create(:shopping_cart, last_interaction_at: 5.days.ago, status: 'abandoned')

                run_job

                expect(recent_cart.reload.status).to(eq('active'))
                expect(recent_cart_2.reload.status).to(eq('active'))
                expect(recent_abandoned_cart.reload.status).to(eq('abandoned'))
                expect(recent_abandoned_cart_2.reload.status).to(eq('abandoned'))
            end
        end

        context 'when there are eligible removed carts (inactive carts for 7 days)' do
            it 'removes only the status == abandoned carts with last_interaction_at > 7 days ago' do
                active_cart = create(:shopping_cart, last_interaction_at: 1.hour.ago, status: 'active')
                old_cart = create(:shopping_cart, last_interaction_at: 1.day.ago, status: 'abandoned')
                old_cart_2 = create(:shopping_cart, last_interaction_at: 6.days.ago, status: 'abandoned')
                old_purgable_cart = create(:shopping_cart, last_interaction_at: 8.days.ago, status: 'abandoned')
                old_purgable_cart_2 = create(:shopping_cart, last_interaction_at: 10.days.ago, status: 'abandoned')

                run_job
                
                expect(Cart.count).to(eq(3))
                expect(old_cart.reload.status).to(eq('abandoned'))
                expect(old_cart_2.reload.status).to(eq('abandoned'))
                expect(active_cart.reload.status).to(eq('active'))
                expect(Cart.exists?(old_purgable_cart.id)).to(eq(false))
                expect(Cart.exists?(old_purgable_cart_2.id)).to(eq(false))
            end
        end
    end
end
