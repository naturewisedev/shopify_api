module ShopifyAPI
  class Checkout < Base
    self.timeout = 1000000

    def id
      @attributes[:token]
    end

    def pay(session_params, &block)
      vault_session = VaultSession.create(session_params)
      pay_with(vault_session, &block)
    end

    def pay_with(vault_session)
      payment = Payment.create_from(self, vault_session)
      yield payment if block_given?
      payment
    end

    class ShippingRate < Base
    end

    class Payment < Base
      def self.create_from(checkout, vault_session)
        self.new.create_with_checkout_and_session(checkout, session)
      end

      def create_from(checkout, vault_session)
        params = { payment: { session_id: session.id } }

        load_attributes_from_response checkout.post(:payments, params)
        self
      end
    end
  end
end
