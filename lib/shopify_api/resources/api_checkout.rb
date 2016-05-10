module ShopifyAPI
  class CheckoutAPI < Base
    self.prefix = '/api/'
    self.element_name = 'checkout'
    self.timeout = 1000000

    def id
      @attributes[:token]
    end

    def pay_with(session)
      Payment.create_with_checkout_and_session(self, session)
    end
  end

  class Payment < Base
    def self.create_with_checkout_and_session(checkout, session)
      self.new.create_with_checkout_and_session(checkout, session)
    end

    def create_with_checkout_and_session(checkout, session)
      load_attributes_from_response checkout.post(:payments, {
        payment: {
          source: {
            session_id: session.id
          }
        }
      })
      self
    end
  end
end