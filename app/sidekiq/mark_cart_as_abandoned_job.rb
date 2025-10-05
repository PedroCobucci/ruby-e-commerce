class MarkCartAsAbandonedJob
    include Sidekiq::Job
    #sidekiq_options queue: 'low'

    def perform(*args)
    # TODO Impletemente um Job para gerenciar, marcar como abandonado. E remover carrinhos sem interação. 

        abandoned_count = Cart.abandonable.update_all(status: 'abandoned')

        if abandoned_count > 0
            puts "[Sidekiq] #{abandoned_count} carrinhos foram marcados como abandonados."
        end

        purged_count = Cart.purgeable.delete_all

        if purged_count > 0
            puts "[Sidekiq] #{purged_count} carrinhos abandonados há muito tempo foram removidos."
        end
    
    end
end
