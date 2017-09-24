class TaxLineItem

  def add_shopify_obj shopify_tax_line
    @title = shopify_tax_line['title']
    @price = shopify_tax_line['price']
    @rate = shopify_tax_line['rate']

    self
  end

  def add_flowlink_obj flowlink_tax_line
    @name = flowlink_tax_line['name']
    @value = flowlink_tax_line['value']
    @rate = flowlink_tax_line['rate']

    self
  end

  def flowlink_obj
    {
      'name' => @title,
      'value' => @price.to_f,
      'rate' => @rate.to_f
    }
  end

  def shopify_obj
    {
      'title' => @name,
      'price' => @value.to_f,
      'rate' => @rate.to_f
    }
  end
end
