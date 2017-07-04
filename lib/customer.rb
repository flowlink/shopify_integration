class Customer

  attr_reader :shopify_id

  def add_shopify_obj shopify_customer, shopify_api
    @shopify_id = shopify_customer['id']
    @firstname = shopify_customer['first_name']
    @lastname = shopify_customer['last_name']
    @email = shopify_customer['email']
    @default_address = Address.new.add_shopify_obj(shopify_customer['default_address'])
    @source = Util.shopify_host shopify_api.config
  end

  def add_flowlink_obj flowlink_customer, shopfiy_api
    @shopify_id = flowlink_customer['shopify_id']
    @firstname = flowlink_customer['firstname']
    @lastname = flowlink_customer['lastname']
    @email = flowlink_customer['email']
    @shipping_address = Address.new.add_flowlink_obj(flowlink_customer['shipping_address'])
    @billing_address = Address.new.add_flowlink_obj(flowlink_customer['billing_address'])
  end

  def flowlink_obj
    {
      'id' => @shopify_id.to_s,
      'shopify_id' => @shopify_id.to_s,
      'source' => @source,
      'firstname' => @firstname,
      'lastname' => @lastname,
      'email' => @email,
      'shipping_address' => @default_address.flowlink_obj,
      'billing_address' => @default_address.flowlink_obj
    }
  end

  def shopify_obj
    {
      'customer' => {
        'first_name' => @firstname,
        'last_name' => @lastname,
        'email' => @email,
        'addresses' => [
          @shipping_address.shopify_obj,
          @billing_address.shopify_obj
        ]
      }
    }
  end

end
