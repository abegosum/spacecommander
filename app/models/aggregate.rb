class Aggregate
  attr_accessor :name, :size, :used, :free, :volumes, :allocated, :metadata_size, :asis_used, :volume_used, :id

  def self.create_from_aggr_attributes_element(aggr_attributes_element)
    aggr_space_attributes_element = aggr_attributes_element.child_get 'aggr-space-attributes'
    current_aggregate = Aggregate.new
    current_aggregate.name = aggr_attributes_element.child_get_string 'aggregate-name'
    current_aggregate.id = aggr_attributes_element.child_get_string 'aggregate-uuid'
    current_aggregate.used = aggr_space_attributes_element.child_get_int 'size-used'
    current_aggregate.free = aggr_space_attributes_element.child_get_int 'size-available'
    current_aggregate.size = aggr_space_attributes_element.child_get_int 'size-total'
    current_aggregate
  end
end
