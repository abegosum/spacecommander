class Aggregate
  extend Byteable
  
  attr_accessor :name, :volume_names, :allocated, :metadata_size, :asis_used, :volume_used, :id, :node_host
  attr_writer :volumes
  bytes_attr_accessor :size, :used, :free

  def volumes
    @volumes = [] unless @volumes
    @volumes
  end

  def total_volume_space_allocated
    @_total_volume_space_allocated ||= begin
                                         space = Bytes.new(0)
                                         volumes.each do |volume|
                                           space = space + volume.allocated
                                         end
                                         space
                                       end
  end

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
