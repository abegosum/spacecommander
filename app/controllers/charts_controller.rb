class ChartsController < ApplicationController
  include NetappEnvironmentConsumer

  before_action :set_physical_manager, only: [ :node_physical_show ] # fire this callback before processing show action
  before_action :set_filer, only: [ :filer_virtual_show ] # fire this callback before processing show action

  def node_physical_show
    render json: {
      "used (#{@physical_manager.total_physical_space_used.to_human_readable_s})" => @physical_manager.total_physical_space_used.to_gb,
      "free (#{@physical_manager.total_physical_space_free.to_human_readable_s})" => @physical_manager.total_physical_space_free.to_gb
    }
  end

  def filer_virtual_show
    render json: {
      "used data (#{@filer.total_volume_space_used.to_human_readable_s})" => @filer.total_volume_space_used.to_gb,
      "free data (#{@filer.total_volume_space_free.to_human_readable_s})" => @filer.total_volume_space_free.to_gb,
      "snapshot reserve (#{@filer.total_volume_space_snapshot_reserve.to_human_readable_s})" => @filer.total_volume_space_snapshot_reserve.to_gb
    }
  end

  private
  def set_physical_manager
    @physical_manager = netapp_environment.find_physical_manager_by_name params[:name]
  end

  def set_filer
    @filer = netapp_environment.find_filer_by_name params[:name]
  end
end
