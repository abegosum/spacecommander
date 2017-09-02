# Class defining the environment as defined by
# config/netapp.yml
class NetappEnvironment

  def self.clusters
    @@_clusters ||= begin
                     clusters = {}
                     Rails.configuration.netapp['clusters'].each do |cluster_host, cluster_config| 
                       api_user = cluster_config['user']
                       password = cluster_config['password']
                       vservers = cluster_config['vservers']
                       clusters[cluster_host] = NetappClusterVif.new cluster_host, api_user, password
                       vservers.each do |vserver_host, vserver_config|
                         api_user = vserver_config['user']
                         password = vserver_config['password']
                         clusters[cluster_host].vservers[vserver_host] = NetappClusterVserver.new vserver_host, api_user, password
                       end
                     end
                     clusters
                   end
  end
  
  def self.sevenmode_nodes
    @@_sevenmode_nodes ||= begin
                             nodes = {}
                             nodes_by_id = {}
                             Rails.configuration.netapp['sevenmode_nodes'].each do |node_host, node_config|
                               api_user = node_config['user']
                               password = node_config['password']
                               node = Netapp7modeNode.new node_host, api_user, password
                               nodes[node_host] = node
                               nodes_by_id[node.id] = node
                             end
                             nodes.each do |node_host, node|
                               node.partner = nodes_by_id[node.partner_id] if node.partner_id
                             end
                             nodes
                           end
  end

  def self.totals
    @@_totals ||= begin
                    totals = Totals.new
                    NetappEnvironment.clusters.each do |clustername, cluster| 

                      cluster.aggregates.each do |aggregate|
                        totals.physical_provisioned += aggregate.size
                        totals.physical_used += aggregate.used
                        totals.physical_available += aggregate.free
                      end
                    
                      cluster.vservers.each do |vservername, vserver|
                        vserver.volumes.each do |volume|
                          totals.volume_provisioned += volume.allocated
                          totals.volume_used += volume.used
                          totals.volume_available += volume.available
                        end
                      end

                    end

                    NetappEnvironment.sevenmode_nodes.each do |nodename, node|

                      node.aggregates.each do |aggregate|
                        totals.physical_provisioned += aggregate.size
                        totals.physical_used += aggregate.used
                        totals.physical_available += aggregate.free
                      end

                      node.volumes.each do |volume|
                        totals.volume_provisioned += volume.allocated
                        totals.volume_used += volume.used
                        totals.volume_available += volume.available
                      end

                    end
                    
                    totals
                  end
  end

  def self.in_kb bytes
    bytes / 1000
  end

  def self.in_mb bytes
    (NetappEnvironment.in_kb bytes) / 1000
  end

  def self.in_gb bytes
    (NetappEnvironment.in_mb bytes) / 1000
  end

  def self.in_tb bytes
    (NetappEnvironment.in_gb bytes) / 1000
  end

  def self.in_pb bytes
    (NetappEnvironment.in_tb bytes) / 1000
  end

  def self.reset_clusters
    @@_clusters = nil
  end

  def self.reset_sevenmode_nodes
    @@_sevenmode_nodes = nil
  end

  def self.reset_totals
    @@_totals = nil
  end

  def self.reset_all_data
    NetappEnvironment.reset_clusters
    NetappEnvironment.reset_sevenmode_nodes
    NetappEnvironment.reset_totals
  end
end
