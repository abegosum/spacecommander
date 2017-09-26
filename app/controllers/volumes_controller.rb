class VolumesController < ApplicationController
  before_action :set_netapp_environment, only: [ :show ] # fire this callback before processing show action
  before_action :set_volume, only: [ :show ] # fire this callback before processing show action

  def index
  end

  def show
    @filer = @netapp_environment.find_filer_by_name @volume.filer_host
    used_gb_rounded = @volume.used.to_gb.round(2)
    available_gb_rounded = @volume.available.to_gb.round(2)
    snapshot_res_gb_rounded = @volume.snapshot_reserve.to_gb.round(2)
    @volume_space_graph = {
      "used (#{used_gb_rounded} GB)"      => @volume.used.to_gb,
      "free (#{available_gb_rounded} GB)" => @volume.available.to_gb
    }
    unless snapshot_res_gb_rounded == 0
      @volume_space_graph["snap reserve (#{snapshot_res_gb_rounded}) GB"] = @volume.snapshot_reserve.to_gb
    end
  end

  private
  def set_netapp_environment
    @netapp_environment = NetappEnvironment.new unless @netapp_environment
  end

  def set_volume
    if params[:id]
      @volume = get_volume_from_id
    else
      @volume = get_volume_from_filer_and_name
    end
  end

  def get_volume_from_filer_and_name
    set_netapp_environment
    filer = @netapp_environment.find_filer_by_name params[:filer_name]
    filer.find_volume_by_name params[:name]
  end

  def get_volume_from_id
    set_netapp_environment
    @netapp_environment.find_volume_by_id params[:id]
  end
end
