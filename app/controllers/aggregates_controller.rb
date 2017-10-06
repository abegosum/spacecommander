#   Copyright 2017 Aaron M. Bond
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#
# Controller to display physical storage devises of NASes.
class AggregatesController < ApplicationController
  include NasEnvironmentConsumer

  before_action :set_aggregate, only: [ :show ] 

  def index
  end

  def show
    @aggregate_space_graph = {
      "used (#{@aggregate.used.to_human_readable_s})" => @aggregate.used.to_gb,
      "free (#{@aggregate.free.to_human_readable_s})" => @aggregate.free.to_gb,
    }
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
