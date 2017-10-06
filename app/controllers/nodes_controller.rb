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
# Controller to display physical storage information for NASes.
class NodesController < ApplicationController
  include NasEnvironmentConsumer

  before_action :set_physical_manager, only: [ :show ] # fire this callback before processing show action
  def index
  end

  def show
    @physical_overview_space_graph = {
      "used (#{@physical_manager.total_physical_space_used.to_human_readable_s})" => @physical_manager.total_physical_space_used.to_gb,
      "free (#{@physical_manager.total_physical_space_free.to_human_readable_s})" => @physical_manager.total_physical_space_free.to_gb,
    }
    @provision_label = "Underprovisioned by:"
    @provision_label = "Overprovisioned by:" unless @physical_manager.total_volume_space_allocated < @physical_manager.total_physical_space
    @provision_value = (@physical_manager.total_physical_space - @physical_manager.total_volume_space_allocated).abs
  end

  private

  def set_physical_manager
    @physical_manager = netapp_environment.find_physical_manager_by_name params[:name]
  end

end
