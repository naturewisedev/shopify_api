module ShopifyAPI
  module VaultSessionFormat
    extend self

    def extension
      "json"
    end

    def mime_type
      "application/json"
    end

    def encode(hash, options = nil)
      ActiveSupport::JSON.encode(hash, options)
    end

    def decode(json)
      ActiveSupport::JSON.decode(json)
    end
  end

  class VaultSession < Base
    self.site = "https://elb.deposit.shopifycs.com"
    self.element_name = "session"
    self.include_format_in_path = false
    self.format = VaultSessionFormat
  end
end
