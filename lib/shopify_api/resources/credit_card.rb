module ShopifyCS
  module SessionFormat
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

  def self.site=(site)
    Session.site = site
  end

  class Session < ActiveResource::Base
    self.site = 'elb.deposit.shopifycs.com'
    self.include_format_in_path = false
    self.format = SessionFormat
  end
end
