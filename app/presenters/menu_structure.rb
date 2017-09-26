class MenuStructure

  def self.nodes
    @@_nodes ||= begin
                   nodes = []
                   Rails.configuration.netapp['clusters'].each do |cluster_host, cluster_config|
                     nodes << cluster_host
                   end
                   Rails.configuration.netapp['sevenmode_nodes'].each do |node_host, node_config|
                     nodes << node_host
                   end
                   nodes
                 end
  end

  def self.filers
    @@_filers ||= begin
                   nodes = []
                   Rails.configuration.netapp['clusters'].each do |cluster_host, cluster_config|
                     vservers = cluster_config['vservers']
                     vservers = {} unless vservers
                     vservers.each do |vserver_host, vserver_config|
                       nodes << vserver_host
                     end
                   end
                   Rails.configuration.netapp['sevenmode_nodes'].each do |node_host, node_config|
                     nodes << node_host
                   end
                   nodes
                 end
  end

  def self.locations
    @@_locations ||= begin
                       locations = []
                       Rails.configuration.netapp['clusters'].each do |host, config|
                         if config['location']
                           locations << config['location']
                         end
                       end
                       Rails.configuration.netapp['sevenmode_nodes'].each do |host, config|
                         if config['location']
                           locations << config['location']
                         end
                       end
                       locations.uniq.sort
                     end
  end

end
