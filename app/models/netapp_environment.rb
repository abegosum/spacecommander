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
# Represents (and inflates) the environment defined by netapp.yml in config/.
# Note that all clusters, 7-mode nodes and locations are cached in the rails
# cache for 12 hours.
class NetappEnvironment

  def clusters
    @_clusters ||= Rails.cache.fetch('clusters', expires_in: 12.hours) do
                     clusters = {}
                     Rails.configuration.nas[:netapp][:clusters].each do |cluster_host, cluster_config| 
                       api_user = cluster_config[:user]
                       password = cluster_config[:password]
                       vservers = cluster_config[:vservers]
                       vservers = {} unless vservers
                       clusters[cluster_host] = NetappClusterVif.new cluster_host, api_user, password
                       clusters[cluster_host].location = cluster_config[:location] if cluster_config[:location]
                       vservers.each do |vserver_host, vserver_config|
                         api_user = vserver_config[:user]
                         password = vserver_config[:password]
                         clusters[cluster_host].vservers[vserver_host] = NetappClusterVserver.new vserver_host.to_s, api_user, password
                       end
                     end
                     populate_vserver_aggregate_volumes clusters
                     clusters
                   end
  end
  
  def sevenmode_nodes
    @_sevenmode_nodes ||= Rails.cache.fetch('sevenmode_nodes', expires_in: 12.hours) do 
                            nodes = {}
                            nodes_by_id = {}
                            Rails.configuration.nas[:netapp][:sevenmode_nodes].each do |node_host, node_config|
                              api_user = node_config[:user]
                              password = node_config[:password]
                              node = Netapp7modeNode.new node_host, api_user, password
                              node.location = node_config[:location] if node_config[:location]
                              nodes[node_host] = node
                              nodes_by_id[node.id] = node
                            end
                            nodes.each do |node_host, node|
                              node.partner = nodes_by_id[node.partner_id] if node.partner_id
                            end
                            nodes
                          end
  end

  def locations
    @_locations ||= Rails.cache.fetch('locations', expires_in: 12.hours) do
                      locations = {}
                      Rails.configuration.nas[:netapp][:clusters].each do |host, config|
                        if config[:location]
                          locations[config[:location]] = {} unless locations[config[:location]]
                          locations[config[:location]][:clusters] = {} unless locations[config[:location]][:clusters]
                          locations[config[:location]][:clusters][host] = clusters[host]
                        end
                      end
                      Rails.configuration.nas[:netapp][:sevenmode_nodes].each do |host, config|
                        if config[:location]
                          locations[config[:location]] = {} unless locations[config[:location]]
                          locations[config[:location]][:sevenmode_nodes] = {} unless locations[config[:location]][:sevenmode_nodes]
                          locations[config[:location]][:sevenmode_nodes][host] = sevenmode_nodes[host]
                        end
                      end
                      locations.each do |name, location|
                        location[:clusters] = {} unless location[:clusters]
                        location[:sevenmode_nodes] = {} unless location[:sevenmode_nodes]
                        location[:totals] = Totals.create_from_netapp_servers location[:clusters], location[:sevenmode_nodes]
                      end
                      locations
                    end
  end

  def find_filer_by_name(name)
    result = nil
    clusters.each do |hostname, cluster|
      cluster.vservers.each do |vserverhostname, vserver| 
        result = vserver if vserverhostname.to_s == name
        break if result
      end
      break if result
    end

    unless result
      sevenmode_nodes.each do |sevenmodehostname, filer|
        result = filer if sevenmodehostname == name
        break if result
      end
    end
    result
  end

  def find_physical_manager_by_name(name)
    result = nil

    clusters.each do |hostname, cluster|
      result = cluster if hostname.to_s == name
      break if result
    end

    unless result
      sevenmode_nodes.each do |sevenmodehostname, node|
        result = node if sevenmodehostname == name
        break if result
      end
    end
    result
  end

  def find_aggregate_by_uuid(uuid)
    result = find_aggregate_by_uuid_in_clusterset uuid, clusters
    sevenmode_nodes.each do |hostname, node|
      node.aggregates.each do |aggregate|
        result = aggregate if aggregate.id == uuid
        break if result
      end
      break if result
    end
    result
  end

  def find_volume_by_id(id)
    result = nil
    clusters.each do |hostname, cluster|
      cluster.vservers.each do |vserverhostname, vserver|
        result = vserver.find_logical_device_by_id id
        break if result
      end
      break if result
    end

    unless result
      sevenmode_nodes.each do |sevenmodehostname, filer|
        result = filer.find_logical_device_by_id id
        break if result
      end
    end
    result
  end

  def totals
    @_totals ||= Totals.create_from_netapp_servers clusters, sevenmode_nodes
  end

  def reset_clusters
    @_clusters = nil
    Rails.cache.delete('clusters')
  end

  def reset_sevenmode_nodes
    @_sevenmode_nodes = nil
    Rails.cache.delete('sevenmode_nodes')
  end

  def reset_locations
    @_locations = nil
    Rails.cache.delete('locations')
  end

  def reset_totals
    @_totals = nil
  end

  def reset_all_data
    reset_clusters
    reset_sevenmode_nodes
    reset_totals
    reset_locations
  end

  private
  def find_aggregate_by_uuid_in_clusterset(uuid, clusterset)
    result = nil
    clusterset.each do |hostname, cluster|
      cluster.aggregates.each do |aggregate|
        result = aggregate if aggregate.id == uuid
        break if result
      end
      break if result
    end
    result
  end

  def populate_vserver_aggregate_volumes(clusterset)
    clusterset.each do |hostname, cluster|
      cluster.vservers.each do |vserverhostname, vserver| 
        vserver.volumes.each do |volume|
          current_aggregate = find_aggregate_by_uuid_in_clusterset volume.containing_aggregate_uuid, clusterset
          current_aggregate.volume_names = [] unless current_aggregate.volume_names
          current_aggregate.volume_names << volume.name
          current_aggregate.volumes << volume
        end
      end
    end
  end
end
