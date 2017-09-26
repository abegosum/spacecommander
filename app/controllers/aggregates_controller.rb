class AggregatesController < ApplicationController
  include NetappEnvironmentConsumer

  before_action :set_aggregate, only: [ :show ] 

  def index
  end

  def show
    @aggregate_space_graph = {
      "used (#{@aggregate.used.to_human_readable_s})" => @aggregate.used.to_gb,
      "free (#{@aggregate.free.to_human_readable_s})" => @aggregate.free.to_gb,
    }
    @aggregate_volumes_space_graph = {}
    @aggregate.volumes.each do |volume|
      @aggregate_volumes_space_graph["#{volume.name} (#{volume.allocated.to_human_readable_s})"] = volume.allocated.to_gb
    end
    @provision_label = "Underprovisioned by:"
    @provision_label = "Overprovisioned by:" unless @aggregate.total_volume_space_allocated < @aggregate.size
    @provision_value = (@aggregate.size - @aggregate.total_volume_space_allocated).abs
  end

  private
  def set_aggregate
    if params[:id]
      @aggregate = get_aggregate_from_id
    else
      @aggregate = get_aggregate_from_node_and_name
    end
  end

  def get_aggregate_from_node_and_name
    physical_manager = netapp_environment.find_physical_manager_by_name params[:node_name]
    physical_manager.find_aggregate_by_name params[:name]
  end

  def get_aggregate_from_id
    netapp_environment.find_aggregate_by_uuid params[:id]
  end

end
