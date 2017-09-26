class PhysicalManagersController < ApplicationController
  before_action :set_physical_manager, only: [ :show ] # fire this callback before processing show action
  before_action :set_netapp_environment, only: [ :show ] # fire this callback before processing show action
  def index
  end

  def show
    @physical_overview_space_graph = {
      "used (#{@physical_manager.total_physical_space_used.to_human_readable_s})" => @physical_manager.total_physical_space_used.to_gb,
      "free (#{@physical_manager.total_physical_space_free.to_human_readable_s})" => @physical_manager.total_physical_space_free.to_gb,
    }
    @aggregates_space_graph = {}
    @physical_manager.aggregates.each do |aggregate|
      @aggregates_space_graph["#{aggregate.name} (#{aggregate.size})"] = aggregate.size.to_gb
    end
  end

  private
  def set_netapp_environment
    @netapp_environment = NetappEnvironment.new unless @netapp_environment
  end

  def set_physical_manager
    set_netapp_environment
    @physical_manager = @netapp_environment.find_physical_manager_by_name params[:name]
  end
end
