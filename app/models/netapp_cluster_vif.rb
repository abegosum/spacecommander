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
# Represents a connection to the vif of a cluster management vserver in 
# NetApp clustered mode, which can manage physical devices (aggregates).
class NetappClusterVif < NetappApiServer
  include PhysicalManager

  attr_accessor :vservers, :nodes

  def initialize(host, init_user, init_pass)
    super
    unless is_cluster?
      raise IncorrectApiTypeError.new("#{host} appears not to be a cluster VIF and cannot be initialized")
    end
    self.vservers = {}
    self.nodes = {}
  end

  def aggregates(force_refresh=false)
    if !@_aggregates || force_refresh
      @_aggregates = []
      api_response = invoke_api_or_fail 'aggr-get-iter'
      next_tag = api_response.child_get_string 'next-tag'
      aggregate_list_element = api_response.child_get 'attributes-list'
      @_aggregates.concat get_aggregates_from_aggr_attributes_array_element aggregate_list_element
      while next_tag && (loop_iter ||= 0) < API_LOOP_LIMIT
         api_response = invoke_api_or_fail 'aggr-get-iter', 'tag', next_tag
         next_tag = api_response.child_get_string 'next-tag'
         aggregate_list_element = api_response.get_child 'attributes-list'
         @_aggregates.concat get_aggregates_from_aggr_attributes_array_element aggregate_list_element
         loop_iter += 1
      end
    end
    @_aggregates
  end

  def id
    @_id ||= get_cluster_identity_info_element.child_get_string('cluster-uuid')
  end

  private
  def get_aggregates_from_aggr_attributes_array_element(aggregate_list_element)
    return [] unless aggregate_list_element
    aggregate_list_element.children_get.map do |aggr_attributes_element|
      current_aggregate = Aggregate.create_from_aggr_attributes_element aggr_attributes_element
      current_aggregate.node_host = host
      current_aggregate
    end
  end

  def get_cluster_identity_info_element
    @_vserver_info_element ||= invoke_api_or_fail('cluster-identity-get').child_get('attributes').child_get('cluster-identity-info')
  end

end
