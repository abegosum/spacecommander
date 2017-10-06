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
# Mixin representing a filer (NetApp server that handles logical devices).
# Expects the volumes member to be declared and to return an array of 
# the Volume model.
module Filer

  def total_volume_space_snapshot_reserve 
    @_total_volume_space_snapshot_reserve ||= begin
                                                space = Bytes.new(0)
                                                logical_devices.each do |logical_device|
                                                  space = space + logical_device.snapshot_reserve
                                                end
                                                space
                                              end
  end


end
