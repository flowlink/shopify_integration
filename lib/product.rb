class Product

  attr_reader :shopify_id, :variants

  def add_shopify_obj shopify_product, shopify_api
    @shopify_id = shopify_product['id']
    @source = Util.shopify_host shopify_api.config
    @name = shopify_product['title']
    @description = shopify_product['body_html']

    @options = Array.new
    unless shopify_product['options'].nil?
      shopify_product['options'].each do |shopify_option|
        option = Option.new
        option.add_shopify_obj shopify_option
        @options << option
      end
    end

    @variants = Array.new
    unless shopify_product['variants'].nil?
      shopify_product['variants'].each do |shopify_variant|
        variant = Variant.new
        variant.add_shopify_obj shopify_variant, shopify_product['options']
        @variants << variant
      end
    end

    @images = Array.new
    unless shopify_product['images'].nil?
      shopify_product['images'].each do |shopify_image|
        image = Image.new
        image.add_shopify_obj shopify_image
        @images << image
      end
    end

    self
  end

  def add_flowlink_obj flowlink_product, shopify_api
    @shopify_id = flowlink_product['shopify_id']
    @flowlink_id = flowlink_product['id'].to_s
    @name = flowlink_product['name']
    @description = flowlink_product['description']

    @options = Array.new
    unless flowlink_product['options'].blank?
      flowlink_product['options'].each do |flowlink_option|
        option = Option.new
        option.add_flowlink_obj flowlink_option
        @options << option
      end
    else
      option = Option.new
      option.add_flowlink_obj 'Default'
      @options << option
    end

    @variants = Array.new
    unless flowlink_product['variants'].nil?
      flowlink_product['variants'].each do |flowlink_variant|
        variant = Variant.new
        variant.add_flowlink_obj flowlink_variant
        @variants << variant
      end
    end

    @images = Array.new
    unless flowlink_product['images'].nil?
      flowlink_product['images'].each do |flowlink_image|
        image = Image.new
        image.add_flowlink_obj flowlink_image
        @images << image
      end
    end
    @variants.each do |variant|
      variant.images.each do |image|
        @images << image
      end
    end

    self
  end

  def flowlink_obj
    {
      'id' => @shopify_id.to_s,
      'shopify_id' => @shopify_id.to_s,
      'source' => @source,
      'name' => @name,
      'sku' => @name,
      'description' => @description,
      'meta_description' => @description,
      'options' => Util.flowlink_array(@options),
      'variants' => Util.flowlink_array(@variants),
      'images' => Util.flowlink_array(@images)
    }
  end

  def shopify_obj
    {
      'product'=> {
        'title'=> @name,
        'body_html'=> @description,
        'product_type' => 'None',
        'options' => Util.shopify_array(@options),
        'variants'=> Util.shopify_array(@variants).map {|v| v["variant"]},
        'images' => Util.shopify_array(@images)
      }
    }
  end

  def shopify_obj_no_variants
    obj_no_variants = shopify_obj
    obj_no_variants['product'].delete('variants')
    obj_no_variants
  end

end
