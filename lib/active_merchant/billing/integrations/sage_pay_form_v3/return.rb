module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    module Integrations #:nodoc:
      module SagePayFormV3
        class Return < ActiveMerchant::Billing::Integrations::Return

          def initialize(query_string, options)
            begin
              @notification = Notification.new(query_string, options)
            rescue Notification::CryptError => e
              @message = e.message
            end
          end

          def success?
            @notification && @notification.complete?
          end

          def cancelled?
            @notification && @notification.cancelled?
          end

          def message
            @message || @notification.message
          end

        end
      end
    end
  end
end
