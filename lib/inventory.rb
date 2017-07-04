class Inventory

  attr_reader :shopify_id, :sku, :quantity

  def add_obj variant
    @sku = variant.sku
    @shopify_id = variant.shopify_id
    @shopify_parent_id = variant.shopify_parent_id
    @quantity = variant.quantity

    self
  end

  def add_flowlink_obj flowlink_inventory
    @sku = flowlink_inventory['product_id']
    @quantity = flowlink_inventory['quantity']
    unless flowlink_inventory['shopify_id'].nil?
      @shopify_id = flowlink_inventory['shopify_id']
    end

    self
  end

  def flowlink_obj
    {
      'id' => @sku,
      'product_id' => @sku,
      'shopify_id' => @shopify_id,
      'shopify_parent_id' => @shopify_parent_id.to_s,
      'quantity' => @quantity
    }
  end

  def shopify_obj
    {
      'inventory_quantity' => @quantity
    }
  end
end
