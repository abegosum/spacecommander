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
# Controller to display logical storage information for NASes.
class VolumesController < ApplicationController
  include NetappEnvironmentConsumer

  before_action :set_volume, only: [ :show ] # fire this callback before processing show action

  def index
  end

  def show
    @filer = netapp_environment.find_filer_by_name @volume.filer_host
    used_gb_rounded = @volume.used.to_gb.round(2)
    available_gb_rounded = @volume.available.to_gb.round(2)
    snapshot_res_gb_rounded = @volume.snapshot_reserve.to_gb.round(2)
    @volume_space_graph = {
      "used (#{used_gb_rounded} GB)"      => @volume.used.to_gb,
      "free (#{available_gb_rounded} GB)" => @volume.available.to_gb
    }
    unless snapshot_res_gb_rounded == 0
      @volume_space_graph["snap reserve (#{snapshot_res_gb_rounded}) GB"] = @volume.snapshot_reserve.to_gb
    end
  end

  private
  def set_volume
    if params[:id]
      @volume = get_volume_from_id
    else
      @volume = get_volume_from_filer_and_name
    end
  end

  def get_volume_from_filer_and_name
    filer = netapp_environment.find_filer_by_name params[:filer_name]
    filer.find_volume_by_name params[:name]
  end

  def get_volume_from_id
    netapp_environment.find_volume_by_id params[:id]
  end
end
