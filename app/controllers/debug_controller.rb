class DebugController < ApplicationController
  def show
    @netapp_environment = NetappEnvironment.new
    @physical_totals_graph = {}
    @netapp_environment.clusters.each do |host, vif|
      @physical_totals_graph[host] = 0
      vif.aggregates.each do |aggregate|
        @physical_totals_graph[host] += aggregate.size.to_tb
      end
    end
    @netapp_environment.sevenmode_nodes.each do |host, node|
      @physical_totals_graph[host] = 0
      node.aggregates.each do |aggregate|
        @physical_totals_graph[host] += aggregate.size.to_tb
      end
    end
    @physical_totals_graph_by_location = {}
    @netapp_environment.locations.each do |location, api_servers|
      @physical_totals_graph_by_location[location] = 0
      api_servers.each do |host, node|
        node.aggregates.each do |aggregate|
          @physical_totals_graph_by_location[location] += aggregate.size.to_tb
        end
      end
    end
  end
end
