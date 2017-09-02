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
end
