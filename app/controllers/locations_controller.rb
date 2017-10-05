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
# Controller to display roll-up information about locations of NASes.
class LocationsController < ApplicationController
  include NetappEnvironmentConsumer

  before_action :set_and_sort_nodes, only: [ :show ] # fire this callback before processing show action
  before_action :set_location, only: [:show]

  def index
    @locations = netapp_environment.locations
    @location_charts = {}
    netapp_environment.locations.each do |location_name, location_config|
      totals = location_config['totals']
      current_chart = {}
      is_under_provisioned = totals.physical_provisioned > totals.volume_provisioned
      provision_label = 'under-provisioned by'
      provision_label = 'over-provisioned by' unless is_under_provisioned
      allocation_label = 'remaining allocated space'
      allocation_label = 'allocated space backed by storage' unless is_under_provisioned
      provision_value = (totals.physical_provisioned - totals.volume_provisioned).abs
      remaining_allocated = totals.volume_provisioned - totals.physical_used
      remaining_allocated = remaining_allocated - provision_value unless is_under_provisioned
      current_chart["used (#{totals.physical_used.to_human_readable_s})"] = totals.physical_used.to_gb
      current_chart["#{allocation_label} (#{remaining_allocated.to_human_readable_s})"] = remaining_allocated.to_gb
      current_chart["#{provision_label} (#{provision_value.to_human_readable_s})"] = provision_value.to_gb
      @location_charts[location_name] = current_chart
    end
  end

  def show
    set_location_physical_totals
    set_location_logical_totals
    set_all_aggregates
    set_all_volumes
    @physical_summary_graph = {
      "used (#{@total_physical_used.to_human_readable_s})" => @total_physical_used.to_gb,
      "free (#{@total_physical_free.to_human_readable_s})" => @total_physical_used.to_gb
    }
    @logical_summary_graph = {
      "used data (#{@total_volume_data_used.to_human_readable_s})" => @total_volume_data_used.to_gb,
      "free data (#{@total_volume_data_free.to_human_readable_s})" => @total_volume_data_free.to_gb,
      "snapshot_reserve (#{@total_volume_snapshot_reserve.to_human_readable_s})" => @total_volume_snapshot_reserve.to_gb
    }
    @provision_label = "Underprovisioned by:"
    @provision_label = "Overprovisioned by:" unless @total_volume_allocated < @total_physical_size
    @provision_value = (@total_physical_size - @total_volume_allocated).abs
  end

  private
  def set_and_sort_nodes
    @cluster_vifs = netapp_environment.locations[params[:name]]['clusters']
    @sevenmode_nodes = netapp_environment.locations[params[:name]]['sevenmode_nodes']
    @filers = @sevenmode_nodes.clone
    @cluster_vifs.values.each do |cluster|
      @filers.merge!(cluster.vservers)
    end
  end

  def set_location_physical_totals
    location_totals = netapp_environment.locations[params[:name]]['totals']
    @total_physical_size ||= location_totals.physical_provisioned
    @total_physical_used ||= location_totals.physical_used
    @total_physical_free ||= location_totals.physical_available
  end

  def set_location_logical_totals
    location_totals = netapp_environment.locations[params[:name]]['totals']
    @total_volume_allocated ||= location_totals.volume_provisioned
    @total_volume_snapshot_reserve ||= location_totals.volume_snapshot_reserve
    @total_volume_data_used ||= location_totals.volume_used
    @total_volume_data_free ||= location_totals.volume_available
  end

  def set_all_aggregates
    clusters = netapp_environment.locations[params[:name]]['clusters']
    sevenmode_nodes = netapp_environment.locations[params[:name]]['sevenmode_nodes']
    @all_aggregates ||= begin
                          aggregates = []
                          clusters.values.each do |cluster_vif|
                            aggregates.concat cluster_vif.aggregates
                          end
                          sevenmode_nodes.values.each do |node|
                            aggregates.concat node.aggregates
                          end
                          aggregates
                        end
  end

  def set_all_volumes
    clusters = netapp_environment.locations[params[:name]]['clusters']
    sevenmode_nodes = netapp_environment.locations[params[:name]]['sevenmode_nodes']
    @all_volumes ||= begin
                       volumes = []
                       clusters.values.each do |cluster_vif|
                         cluster_vif.vservers.values.each do |vserver|
                           volumes.concat vserver.volumes
                         end
                       end
                       sevenmode_nodes.values.each do |node|
                         volumes.concat node.volumes
                       end
                       volumes
                     end
  end


  def set_location
    @location = params[:name]
  end
end
