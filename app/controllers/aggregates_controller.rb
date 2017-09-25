class AggregatesController < ApplicationController
  before_action :set_netapp_environment, only: [ :view ] # fire this callback before processing show action
  before_action :set_aggregate, only: [ :view ] 

  def list
  end

  def view
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
  def set_netapp_environment
    @netapp_environment = NetappEnvironment.new unless @netapp_environment
  end

  def set_aggregate
    if params[:uuid]
      @aggregate = get_aggregate_from_uuid
    end
  end

  def get_aggregate_from_uuid
    set_netapp_environment
    @netapp_environment.find_aggregate_by_uuid params[:uuid]
  end

end
