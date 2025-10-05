class MarkCartAsAbandonedJob
    include Sidekiq::Job

    def perform(*args)
    # TODO Impletemente um Job para gerenciar, marcar como abandonado. E remover carrinhos sem interação. 
        Rails.logger.info "Starting MarkCartAsAbandonedJob..."

        abandoned_count = Cart.abandonable.update_all(status: 'abandoned')

        if abandoned_count > 0
            Rails.logger.info "#{abandoned_count} carts marked as abandoned."
        else
            Rails.logger.info "No carts to mark as abandoned."
        end
    end
end
