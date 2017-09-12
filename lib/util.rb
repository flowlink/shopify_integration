class Util

  def self.flowlink_array objs
    flowlink_array = Array.new
    objs.each do |obj|
      flowlink_obj = obj.flowlink_obj
      if flowlink_obj.kind_of?(Array)
        flowlink_array += obj.flowlink_obj
      else
        flowlink_array << obj.flowlink_obj
      end
    end
    flowlink_array
  end

  def self.shopify_array objs
    shopify_array = Array.new
    objs.each do |obj|
      shopify_array << obj.shopify_obj
    end
    shopify_array
  end

  def self.flowlink_shipment_status shopify_status
    (shopify_status == 'success') ? 'shipped' : 'ready'
  end

  def self.shopify_shipment_status flowlink_status
    shopify_status = 'error'

    case flowlink_status
    when 'shipped'
      shopify_status = 'success'
    when 'ready'
      shopify_status = 'pending'
    else
      shopify_status = 'failure'
    end

    shopify_status
  end

  def self.shopify_apikey flowlink_config
    flowlink_config['shopify_apikey']
  end

  def self.shopify_password flowlink_config
    flowlink_config['shopify_password']
  end

  def self.shopify_host flowlink_config
    flowlink_config['shopify_host']
  end

  def self.flowlink_order_id flowlink_config, shopify_order_number
    store_name = self.shopify_host(flowlink_config).split('.')[0]
    order_prefix = flowlink_config['shopify_order_prefix']
    if order_prefix.nil? || order_prefix.empty?
      return store_name.upcase + '-' + shopify_order_number.to_s
    else
      return order_prefix + shopify_order_number.to_s
    end
  end

end
