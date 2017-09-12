require 'json'
require 'rest-client'
require 'pp'

class ShopifyAPI

  attr_accessor :order, :config, :payload, :request

  def initialize payload, config={}
    @payload = payload
    @config = config
  end

  def get_products
    inventories = Array.new
    products = get_objs('products', Product)
    products.each do |product|
      unless product.variants.nil?
        product.variants.each do |variant|
          unless variant.sku.blank?
            inventory = Inventory.new
            inventory.add_obj variant
            inventories << inventory.flowlink_obj
          end
        end
      end
    end

    {
      'objects' => Util.flowlink_array(products),
      'message' => "Successfully retrieved #{products.length} products " +
                   "from Shopify.",
      'additional_objs' => inventories,
      'additional_objs_name' => 'inventory'
    }
  end

  def get_customers
    get_webhook_results 'customers', Customer
  end

  def get_inventory
    inventories = Array.new
    get_objs('products', Product).each do |product|
      unless product.variants.nil?
        product.variants.each do |variant|
          unless variant.sku.blank?
            inventory = Inventory.new
            inventory.add_obj variant
            inventories << inventory.flowlink_obj
          end
        end
      end
    end
    get_reply inventories, "Retrieved inventories."
  end

  def get_shipments
    shipments = Array.new
    get_objs('orders', Order).each do |order|
      shipments += shipments(order.shopify_id)
    end
    get_webhook_results 'shipments', shipments, false
  end

  def get_orders
    get_webhook_results 'orders', Order
    orders = Util.flowlink_array(get_objs('orders', Order))

    response = {
      'objects' => orders,
      'message' => "Successfully retrieved #{orders.length} orders " +
                   "from Shopify."
    }

    # config to return corresponding shipments
    if @config[:create_shipments].to_i == 1
      shipments = Array.new
      orders.each do |order|
        shipments << Shipment.flowlink_obj_from_order(order)
      end

      response.merge({
        'additional_objs' => shipments,
        'additional_objs_name' => 'shipment'
      })
    else
      response
    end
  end

  def add_product
    product = Product.new
    product.add_flowlink_obj @payload['product'], self
    result = Shopify::APIHelper.api_post 'products.json',
                                         product.shopify_obj,
                                         @config

    {
      'objects' => result,
      'message' => "Product added with Shopify ID of " +
                   "#{result['product']['id']} was added."
    }
  end

  def update_product
    product = Product.new
    product.add_flowlink_obj @payload['product'], self

    ## Using shopify_obj_no_variants is a workaround until
    ## specifying variants' Shopify IDs is added
    master_result = Shopify::APIHelper.api_put "products/#{product.shopify_id}.json",
                                               product.shopify_obj_no_variants,
                                               @config

    product.variants.each do |variant|
      if variant_id = (variant.shopify_id || find_variant_shopify_id(product.shopify_id, variant.sku))
        Shopify::APIHelper.api_put "variants/#{variant_id}.json",
                                   variant.shopify_obj,
                                   @config
      else
        begin
          Shopify::APIHelper.api_post(
            "products/#{product.shopify_id}/variants.json",
            variant.shopify_obj,
            @config)
        rescue RestClient::UnprocessableEntity
          # theres already a variant with same options, bail.
        end
      end
    end

    {
      'objects' => master_result,
      'message' => "Product with Shopify ID of " +
                   "#{master_result['product']['id']} was updated."
    }
  end

  def add_customer
    customer = Customer.new
    customer.add_flowlink_obj @payload['customer'], self
    result = Shopify::APIHelper.api_post 'customers.json',
                                         customer.shopify_obj,
                                         @config

    {
      'objects' => result,
      'message' => "Customer with Shopify ID of " +
                   "#{result['customer']['id']} was added."
    }
  end

  def update_customer
    customer = Customer.new
    customer.add_flowlink_obj @payload['customer'], self

    begin
      result = Shopify::APIHelper.api_put "customers/#{customer.shopify_id}.json",
                                          customer.shopify_obj,
                                          @config
    rescue RestClient::UnprocessableEntity => _e
      # retries without addresses to avoid duplication bug
      customer_without_addresses = customer.shopify_obj
      customer_without_addresses["customer"].delete("addresses")

      result = Shopify::APIHelper.api_put "customers/#{customer.shopify_id}.json",
                                          customer_without_addresses,
                                          @config
    end

    {
      'objects' => result,
      'message' => "Customer with Shopify ID of " +
                   "#{result['customer']['id']} was updated."
    }
  end

  def set_inventory
    inventory = Inventory.new
    inventory.add_flowlink_obj @payload['inventory']
    puts "INV: " + @payload['inventory'].to_json
    shopify_id = inventory.shopify_id.blank? ?
                    find_product_shopify_id_by_sku(inventory.sku) : inventory.shopify_id

    message = 'Could not find item with SKU of ' + inventory.sku
    unless shopify_id.blank?
      result = Shopify::APIHelper.api_put "variants/#{shopify_id}.json",
                                          {'variant' => inventory.shopify_obj},
                                          @config
      message = "Set inventory of SKU #{inventory.sku} " +
                "to #{inventory.quantity}."
    end
    {
      'objects' => result,
      'message' => message
    }
  end

  def add_metafield obj_name, shopify_id, flowlink_id
    api_obj_name = (obj_name == "inventory" ? "product" : obj_name)

    Shopify::APIHelper.api_post "#{api_obj_name}s/#{shopify_id}/metafields.json",
                                Metafield.new(@payload[obj_name]['id']).shopify_obj,
                                @config
  end

  def flowlink_id_metafield obj_name, shopify_id
    flowlink_id = nil

    api_obj_name = (obj_name == "inventory" ? "product" : obj_name)

    metafields_array = Shopify::APIHelper.api_get "#{api_obj_name}s/#{shopify_id}/metafields",
                                                  {}, @config
    unless metafields_array.nil? || metafields_array['metafields'].nil?
      metafields_array['metafields'].each do |metafield|
        if metafield['key'] == 'flowlink_id'
          flowlink_id = metafield['value']
          break
        end
      end
    end

    flowlink_id
  end

  def order order_id
    get_objs "orders/#{order_id}", Order
  end

  def transactions order_id
    get_objs "orders/#{order_id}/transactions", Transaction
  end

  def shipments order_id
    get_objs "orders/#{order_id}/fulfillments", Shipment
  end


  private

  def get_webhook_results obj_name, obj, get_objs = true
    objs = Util.flowlink_array(get_objs ? get_objs(obj_name, obj) : obj)
    get_reply objs, "Successfully retrieved #{objs.length} #{obj_name} " +
                    "from Shopify."
  end

  def get_reply objs, message
    {
      'objects' => objs,
      'message' => message
    }
  end

  def get_objs objs_name, obj_class
    objs = Array.new
    shopify_objs = Shopify::APIHelper.api_get objs_name, {}, @config
    if shopify_objs.values.first.kind_of?(Array)
      shopify_objs.values.first.each do |shopify_obj|
        obj = obj_class.new
        obj.add_shopify_obj shopify_obj, self
        objs << obj
      end
    else
      obj = obj_class.new
      obj.add_shopify_obj shopify_objs.values.first, self
      objs << obj
    end

    objs
  end

  def find_variant_shopify_id(product_shopify_id, variant_sku)
    variants = Shopify::APIHelper.api_get(
      "products/#{product_shopify_id}/variants", {}, @config
    )["variants"],

    if variant = variants.find {|v| v["sku"] == variant_sku}
      variant["id"]
    end
  end

  def find_product_shopify_id_by_sku sku
    count = (Shopify::APIHelper.api_get 'products/count', {}, @config)['count']
    page_size = 250
    pages = (count / page_size.to_f).ceil
    current_page = 1

    while current_page <= pages do
      products = Shopify::APIHelper.api_get 'products',
                                            {'limit' => page_size, 'page' => current_page},
                                            @config
      current_page += 1
      products['products'].each do |product|
        product['variants'].each do |variant|
          return variant['id'].to_s if variant['sku'] == sku
        end
      end
    end

    return nil
  end
end

class AuthenticationError < StandardError; end
class ShopifyError < StandardError; end
