module ShopifyAPI
  class Checkout < Base
    self.timeout = 1000000

    def id
      @attributes[:token]
    end

    def pay(session_params, &block)
      binding.pry
      vault_session = VaultSession.create(session_params)
      pay_with(vault_session, &block)
    end

    def pay_with(vault_session, &block)
      Payment.create_from(self, vault_session)
        .tap(&block)
    end

    class ShippingRate < Base
    end

    class Payment < Base
      def self.create_from(checkout, vault_session)
        new.create_from(checkout, session)
      end

      def create_from(checkout, vault_session)
        params = { payment: { session_id: session.id } }

        load_attributes_from_response(checkout.post(:payments, params))
        self
      end
    end
  end
end
