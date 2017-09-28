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
      "snapshot_reserve (#{@total_volume_snapshot_reserve.to_human_readable_s})" => @total_volume_snapshot_reserve.to_gb
    }
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

  def set_location
    @location = params[:name]
  end
end
