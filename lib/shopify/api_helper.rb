module Shopify
  module APIHelper
    @@api_limit = 0.6
    @@last_api_time = Time.now - @@api_limit

    def self.api_get resource, data, config
      params = ''
      unless data.empty?
        params = '?'
        data.each do |key, value|
          params += '&' unless params == '?'
          params += "#{key}=#{value}"
        end
      end

      puts "REST: api_get: " + (self.final_resource resource, config)
      self.wait_for_api_limit
      response = RestClient.get (self.shopify_url config) +
                                (self.final_resource resource, config) + params
      JSON.parse response.force_encoding("utf-8")
    end

    def self.api_post resource, data, config
      puts "REST: api_post"
      self.wait_for_api_limit
      response = RestClient.post (self.shopify_url config) + resource, data.to_json,
        :content_type => :json, :accept => :json
      JSON.parse response.force_encoding("utf-8")
    end

    def self.api_put resource, data, config
      puts "REST: api_put"
      self.wait_for_api_limit
      response = RestClient.put (self.shopify_url config) + resource, data.to_json,
        :content_type => :json, :accept => :json
      JSON.parse response.force_encoding("utf-8")
    end

    def self.shopify_url config
      "https://#{Util.shopify_apikey config}:#{Util.shopify_password config}" +
      "@#{Util.shopify_host config}/admin/"
    end

    def self.final_resource resource, config
      if !config['since'].nil?
        resource += ".json?updated_at_min=#{config['since']}"
      elsif !config['id'].nil?
        resource += "/#{config['id']}.json"
      else
        resource += '.json'
      end
      resource
    end

    def self.wait_for_api_limit
      time_since_last_api_call = Time.now - @@last_api_time
      if time_since_last_api_call < @@api_limit
        puts "Sleeping for " + (@@api_limit - time_since_last_api_call).to_s
        sleep (@@api_limit - time_since_last_api_call)
      end
      @@last_api_time = Time.now
    end

  end
end
