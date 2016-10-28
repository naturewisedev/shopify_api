require 'test_helper'

class CheckoutsTest < Test::Unit::TestCase
  test "get all should get all orders" do
    fake 'checkouts', :method => :get, :status => 200, :body => load_fixture('checkouts')
    checkout = ShopifyAPI::Checkout.all
    assert_equal 450789469, checkout.first.id
  end

  test "get an existing checkout by token" do
    fake "checkouts/exuw7apwoycchjuwtiqg8nytfhphr62a", method: :get, status: 200, body: load_fixture("checkout")

    checkout = ShopifyAPI::Checkout.find("exuw7apwoycchjuwtiqg8nytfhphr62a")

    assert_nil checkout.order
    assert_equal "exuw7apwoycchjuwtiqg8nytfhphr62a", checkout.token
    assert_equal 49148385, checkout.line_items[0].variant_id
  end

  test "create a new checkout" do
    fake "checkouts", method: :post, status: 201, body: load_fixture("checkout")
    params = {
      email: "bob.norman@hostmail.com",
      line_items: [
        { quantity:1, variant_id: 49148385 },
        { quantity:1, variant_id: 808950810 }
      ],
    }

    checkout = ShopifyAPI::Checkout.create(params)

    assert_equal [49148385, 808950810], checkout.line_items.map(&:variant_id)
    assert_equal "exuw7apwoycchjuwtiqg8nytfhphr62a", checkout.token
  end

  def test_pay_using_a_credit_card
  # test "create a new payment using a payment session" do
    vault_url = "#{ShopifyAPI::VaultSession.site}#{ShopifyAPI::VaultSession.collection_path}"
    binding.pry
    fake "vault_session", method: :post, status: 201, url: vault_url, body: load_fixture("vault_session")
    fake "checkout/exuw7apwoycchjuwtiqg8nytfhphr62a/payments", method: :post, status: 201,
      body: load_fixture("checkout_payment")

    params = {
      payment: {
        amount: "398.00",
        unique_token: "my_idempotency_token",
        credit_card: {
          number: "4242"*4,
          first_name: "Bob",
          last_name: "Norman",
          month: "12",
          year: "2019",
          verification_value: "123",
        }
      }
    }

    checkout = ShopifyAPI::Checkout.new(id: "exuw7apwoycchjuwtiqg8nytfhphr62a")
    checkout.pay(params) do |payment|
      assert_equal 123456789, payment.id
      assert_equal "my_idempotency_token", payment.unique_token
    end
  end


  # def "create a new checkout"
  #
  # test "post a payment using a vaulted session" do
  #   fake "vault_session", method: :post, status: 201, body: load_fixture("vault_session")
  #   fake "checkout_payment", method: :post, status: 202, body: load_fixture("checkout_payment")
  # end
end
