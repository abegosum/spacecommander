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
# A presenter to provide menu items based on configuration pulled from netapp.yml.
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
