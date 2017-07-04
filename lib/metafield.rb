class Metafield

  def initialize flowlink_id
    @flowlink_id = flowlink_id
  end

  def shopify_obj
    {
      'metafield' => {
        'namespace' => 'flowlink',
        'key' => 'flowlink_id',
        'value' => @flowlink_id,
        'value_type' => 'string'
      }
    }
  end
end
