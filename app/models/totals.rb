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
# Represents a roll-up sumation of the space statistics on a set of NASes.
class Totals
  extend Byteable

  bytes_attr_accessor :physical_provisioned, :physical_used, :physical_available, :volume_provisioned, :volume_used, :volume_available, :volume_snapshot_reserve

  def initialize
    self.physical_provisioned = 0
    self.physical_used = 0
    self.physical_available = 0
    self.volume_provisioned = 0
    self.volume_used = 0
    self.volume_available = 0
    self.volume_snapshot_reserve = 0
  end

  def self.create_from_netapp_servers clusters, sevenmode_nodes

    totals = new
    clusters = {} unless clusters
    sevenmode_nodes = {} unless sevenmode_nodes
    
    clusters.each do |clustername, cluster| 
    
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
          totals.volume_snapshot_reserve += volume.snapshot_reserve
        end
      end
    
    end
    
    sevenmode_nodes.each do |nodename, node|
    
      node.aggregates.each do |aggregate|
        totals.physical_provisioned += aggregate.size
        totals.physical_used += aggregate.used
        totals.physical_available += aggregate.free
      end
    
      node.volumes.each do |volume|
        totals.volume_provisioned += volume.allocated
        totals.volume_used += volume.used
        totals.volume_available += volume.available
        totals.volume_snapshot_reserve += volume.snapshot_reserve
      end
    
    end
    
    totals
  end

end
