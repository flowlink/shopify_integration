class Option

  def add_flowlink_obj flowlink_option
    @name = flowlink_option
  end
  
  def add_shopify_obj shopify_option
    @name = shopify_option['name']
  end
  
  def flowlink_obj
    @name
  end

  def shopify_obj
    {
      'name' => @name,
    }
  end
end
