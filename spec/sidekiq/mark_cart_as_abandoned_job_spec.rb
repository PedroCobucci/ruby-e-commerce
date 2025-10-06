require 'rails_helper'
RSpec.describe MarkCartAsAbandonedJob, type: :job do
    subject(:run_job) { described_class.new.perform }

    describe "#perform" do
        context 'when there are no eligible abandoned carts (all active carts)' do
            it 'does not change the status of any cart' do
                recent_cart = create(:shopping_cart, last_interaction_at: 1.hour.ago, status: 'active')
                recent_cart_2 = create(:shopping_cart, last_interaction_at: 2.hours.ago, status: 'active')

                run_job

                expect(recent_cart.reload.status).to(eq('active'))
                expect(recent_cart_2.reload.status).to(eq('active'))
            end
        end

        context 'when there are eligible inactive carts (last_interaction_at < 3 hours ago)' do
            it 'marks only the 3hours > interaction carts as abandoned' do
                
                recent_cart = create(:shopping_cart, last_interaction_at: 1.hour.ago, status: 'active')
                recent_cart_2 = create(:shopping_cart, last_interaction_at: 2.hours.ago, status: 'active')
                old_cart = create(:shopping_cart, last_interaction_at: 4.hours.ago, status: 'active')
                old_cart_2 = create(:shopping_cart, last_interaction_at: 4.hours.ago, status: 'active')

                run_job

                expect(old_cart.reload.status).to(eq('abandoned'))
                expect(old_cart_2.reload.status).to(eq('abandoned'))
                expect(recent_cart.reload.status).to(eq('active'))
                expect(recent_cart_2.reload.status).to(eq('active'))
            end
        end
    end
end
