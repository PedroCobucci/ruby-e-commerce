class PurgeAbandonedCartsJob
    include Sidekiq::Job

    def perform(*args)
        Rails.logger.info "Starting PurgeAbandonedCartsJob..."
        purged_count = Cart.purgeable.delete_all

        if purged_count > 0
            Rails.logger.info "#{purged_count} abandoned carts removed."
        else
            Rails.logger.info "No abandoned carts to purge."
        end
    end
end
