class DebugController < ApplicationController
  def show
    @physical_totals_graph = {}
    NetappEnvironment.clusters.each do |host, vif|
      @physical_totals_graph[host] = 0
      vif.aggregates.each do |aggregate|
        @physical_totals_graph[host] += aggregate.size.to_tb
      end
    end
    NetappEnvironment.sevenmode_nodes.each do |host, node|
      @physical_totals_graph[host] = 0
      node.aggregates.each do |aggregate|
        @physical_totals_graph[host] += aggregate.size.to_tb
      end
    end
  end
end
