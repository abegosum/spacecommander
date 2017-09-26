class LocationsController < ApplicationController
  include NetappEnvironmentConsumer

  before_action :set_and_sort_nodes, only: [ :show ] # fire this callback before processing show action
  before_action :set_location, only: [:show]

  def index
  end

  def show
    set_location_physical_totals
    set_location_logical_totals
    set_all_aggregates
    @physical_summary_graph = {
      "used (#{@total_physical_used.to_human_readable_s})" => @total_physical_used.to_gb,
      "free (#{@total_physical_free.to_human_readable_s})" => @total_physical_used.to_gb
    }
    @aggregate_sizes = { }
    @all_aggregates.each do |aggregate|
      @aggregate_sizes["#{aggregate.name} (#{aggregate.size.to_human_readable_s})"] = aggregate.size.to_gb
    end
    @logical_summary_graph = {
      "used data (#{@total_volume_data_used.to_human_readable_s})" => @total_volume_data_used.to_gb,
      "free data (#{@total_volume_data_free.to_human_readable_s})" => @total_volume_data_free.to_gb,
      "snapshot_reserve (#{@total_volume_data_free.to_human_readable_s})" => @total_volume_data_free.to_gb
    }
  end

  private
  def set_and_sort_nodes
    @cluster_vifs = {}
    @sevenmode_nodes = {}
    @ha_pairs = []
    netapp_environment.clusters.each do |clustername, cluster|
      @cluster_vifs[clustername] = cluster if cluster.location == params[:name]
    end
    netapp_environment.sevenmode_nodes.each do |nodename, node|
      if node.location == params[:name]
        @sevenmode_nodes[nodename] = node
        if node.partner
          @ha_pairs << [node, node.partner] unless @sevenmode_nodes[node.partner.host]
        end
      end
    end
  end

  def set_location_physical_totals
    @total_physical_size ||= begin
                               size = Bytes.new(0)
                               @cluster_vifs.values.each do |cluster_vif|
                                 cluster_vif.aggregates.each do |aggregate|
                                   size = size + aggregate.size
                                 end
                               end
                               @sevenmode_nodes.values.each do |node|
                                 node.aggregates.each do |aggregate|
                                   size = size + aggregate.size
                                 end
                               end
                               size
                             end
    @total_physical_used ||= begin
                               size = Bytes.new(0)
                               @cluster_vifs.values.each do |cluster_vif|
                                 cluster_vif.aggregates.each do |aggregate|
                                   size = size + aggregate.used
                                 end
                               end
                               @sevenmode_nodes.values.each do |node|
                                 node.aggregates.each do |aggregate|
                                   size = size + aggregate.used
                                 end
                               end
                               size
                             end
    @total_physical_free ||= begin
                               size = Bytes.new(0)
                               @cluster_vifs.values.each do |cluster_vif|
                                 cluster_vif.aggregates.each do |aggregate|
                                   size = size + aggregate.free
                                 end
                               end
                               @sevenmode_nodes.values.each do |node|
                                 node.aggregates.each do |aggregate|
                                   size = size + aggregate.free
                                 end
                               end
                               size
                             end
  end

  def set_location_logical_totals
    @total_volume_allocated ||= begin
                                  size = Bytes.new(0)
                                  @cluster_vifs.values.each do |cluster_vif|
                                    cluster_vif.vservers.values.each do |vserver|
                                      vserver.volumes.each do |volume|
                                        size = size + volume.allocated
                                      end
                                    end
                                  end
                                  @sevenmode_nodes.values.each do |node|
                                    node.volumes.each do |volume|
                                      size = size + volume.allocated
                                    end
                                  end
                                  size
                                end
    @total_volume_snapshot_reserve ||= begin
                                         size = Bytes.new(0)
                                         @cluster_vifs.values.each do |cluster_vif|
                                           cluster_vif.vservers.values.each do |vserver|
                                             vserver.volumes.each do |volume|
                                               size = size + volume.snapshot_reserve
                                             end
                                           end
                                         end
                                         @sevenmode_nodes.values.each do |node|
                                           node.volumes.each do |volume|
                                             size = size + volume.snapshot_reserve
                                           end
                                         end
                                         size
                                       end
    
    @total_volume_data_used ||= begin
                                  size = Bytes.new(0)
                                  @cluster_vifs.values.each do |cluster_vif|
                                    cluster_vif.vservers.values.each do |vserver|
                                      vserver.volumes.each do |volume|
                                        size = size + volume.used
                                      end
                                    end
                                  end
                                  @sevenmode_nodes.values.each do |node|
                                    node.volumes.each do |volume|
                                      size = size + volume.used
                                    end
                                  end
                                  size
                                end

    @total_volume_data_free ||= begin
                                  size = Bytes.new(0)
                                  @cluster_vifs.values.each do |cluster_vif|
                                    cluster_vif.vservers.values.each do |vserver|
                                      vserver.volumes.each do |volume|
                                        size = size + volume.available
                                      end
                                    end
                                  end
                                  @sevenmode_nodes.values.each do |node|
                                    node.volumes.each do |volume|
                                      size = size + volume.available
                                    end
                                  end
                                  size
                                end
  end

  def set_all_aggregates
    @all_aggregates ||= begin
                          aggregates = []
                          @cluster_vifs.values.each do |cluster_vif|
                            aggregates.concat cluster_vif.aggregates
                          end
                          @sevenmode_nodes.values.each do |node|
                            aggregates.concat node.aggregates
                          end
                          aggregates
                        end
  end

  def set_location
    @location = params[:name]
  end
end
