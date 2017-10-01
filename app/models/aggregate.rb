#   Copyright 2017 Aaron M. Bond
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#
# Represents a physical storage device on a NAS.
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
