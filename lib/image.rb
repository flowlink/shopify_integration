class Image
  attr_reader :url, :position

  def add_shopify_obj shopify_image
    @url = shopify_image['src']
    @position = shopify_image['position']
  end

  def add_flowlink_obj flowlink_image
    @url = flowlink_image['url']
    @position = flowlink_image['position']
  end

  def flowlink_obj
    {
      'url' => @url,
      'position' => @position
    }
  end

  def shopify_obj
    {
      'src' => @url,
      'position' => @position
    }
  end
end
