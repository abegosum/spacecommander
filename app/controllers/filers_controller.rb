class FilersController < ApplicationController
  before_action :set_filer, only: [ :show ] # fire this callback before processing show action
  before_action :set_netapp_environment, only: [ :show ] # fire this callback before processing show action

  def index
  end

  def show
    @filer_volumes_space_graph = {}
    @filer.volumes.each do |volume|
      @filer_volumes_space_graph["#{volume.name} (#{volume.allocated.to_human_readable_s})"] = volume.allocated.to_gb
    end
  end

  private
  def set_netapp_environment
    @netapp_environment = NetappEnvironment.new unless @netapp_environment
  end

  def set_filer
    set_netapp_environment
    @filer = @netapp_environment.find_filer_by_name params[:name]
  end
end
