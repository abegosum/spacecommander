class FilersController < ApplicationController
  include NetappEnvironmentConsumer

  before_action :set_filer, only: [ :show ] # fire this callback before processing show action

  def index
  end

  def show
    @filer_volume_overview_space_graph = {
      "used (#{@filer.total_volume_space_used.to_human_readable_s})" => @filer.total_volume_space_used.to_gb,
      "free (#{@filer.total_volume_space_free.to_human_readable_s})" => @filer.total_volume_space_free.to_gb,
    }
    unless @filer.total_volume_space_snapshot_reserve == 0
      @filer_volume_overview_space_graph["snap reserve (#{@filer.total_volume_space_snapshot_reserve.to_human_readable_s})"] = @filer.total_volume_space_snapshot_reserve.to_gb
    end
    @filer_volumes_space_graph = {}
    @filer.volumes.each do |volume|
      @filer_volumes_space_graph["#{volume.name} (#{volume.allocated.to_human_readable_s})"] = volume.allocated.to_gb
    end
  end

  private
  def set_filer
    @filer = netapp_environment.find_filer_by_name params[:name]
  end
end
