class Address

  def add_shopify_obj shopify_address
    return self if shopify_address.nil?
    
    @address1 = shopify_address['address1']
    @address2 = shopify_address['address2']
    @zipcode = shopify_address['zip']
    @city = shopify_address['city']
    @state = shopify_address['province']
    @country = shopify_address['country_code']
    @phone = shopify_address['phone']
    
    self
  end
  
  def add_flowlink_obj flowlink_address
    return self if flowlink_address.nil?

    @address1 = flowlink_address['address1']
    @address2 = flowlink_address['address2']
    @zipcode = flowlink_address['zipcode']
    @city = flowlink_address['city']
    @state = flowlink_address['state']
    @country = flowlink_address['country']
    @phone = flowlink_address['phone']
    
    self
  end
  
  def flowlink_obj
    {
      'address1' => @address1.nil? ? "" : @address1,
      'address2' => @address2.nil? ? "" : @address2,
      'zipcode' => @zipcode.nil? ? "" : @zipcode,
      'city' => @city.nil? ? "" : @city,
      'state' => @state.nil? ? "" : @state,
      'country' => @country.nil? ? "" : @country,
      'phone' => @phone.nil? ? "" : @phone
    }
  end
  
  def shopify_obj
    {
      'address1' => @address1.nil? ? "" : @address1,
      'address2' => @address2.nil? ? "" : @address2,
      'zip' => @zipcode.nil? ? "" : @zipcode,
      'city' => @city.nil? ? "" : @city,
      'province' => @state.nil? ? "" : @state,
      'country' => @country.nil? ? "" : @country,
      'phone' => @phone.nil? ? "" : @phone
    }
  end

end
