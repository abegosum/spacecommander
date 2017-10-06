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
# Controller to display logical volume from a NetApp Filer
class FilersController < ApplicationController
  include NasEnvironmentConsumer

  before_action :set_filer, only: [ :show ] # fire this callback before processing show action

  def index
  end

  def show
    @filer_volume_overview_space_graph = {
      "used (#{@filer.total_logical_device_space_used.to_human_readable_s})" => @filer.total_logical_device_space_used.to_gb,
      "free (#{@filer.total_logical_device_space_free.to_human_readable_s})" => @filer.total_logical_device_space_free.to_gb,
    }
    unless @filer.total_volume_space_snapshot_reserve == 0
      @filer_volume_overview_space_graph["snap reserve (#{@filer.total_volume_space_snapshot_reserve.to_human_readable_s})"] = @filer.total_volume_space_snapshot_reserve.to_gb
    end
    @filer_volumes_space_graph = {}
    (@filer.volumes.sort_by{|volume|volume.allocated}).reverse.each do |volume|
      @filer_volumes_space_graph["#{volume.name} (#{volume.allocated.to_human_readable_s})"] = volume.allocated.to_gb
    end
  end

  private
  def set_filer
    @filer = netapp_environment.find_filer_by_name params[:name]
  end
end
