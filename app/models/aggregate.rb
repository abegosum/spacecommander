class Aggregate
  extend Byteable
  
  attr_accessor :name, :volumes, :allocated, :metadata_size, :asis_used, :volume_used, :id
  bytes_attr_accessor :size, :used, :free

  def self.create_from_aggr_attributes_element(aggr_attributes_element)
    aggr_space_attributes_element = aggr_attributes_element.child_get 'aggr-space-attributes'
    current_aggregate = new
    current_aggregate.name = aggr_attributes_element.child_get_string 'aggregate-name'
    current_aggregate.id = aggr_attributes_element.child_get_string 'aggregate-uuid'
    current_aggregate.used = Bytes.new(aggr_space_attributes_element.child_get_int 'size-used')
    current_aggregate.free = Bytes.new(aggr_space_attributes_element.child_get_int 'size-available')
    current_aggregate.size = Bytes.new(aggr_space_attributes_element.child_get_int 'size-total')
    current_aggregate
  end

end
