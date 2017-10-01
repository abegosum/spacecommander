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
# Controller to render json elements for chartkick charts
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
