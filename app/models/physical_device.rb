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
# Represents a physical storage device on a NAS.
class PhysicalDevice
  extend Byteable

  attr_accessor :name, :logical_device_names, :allocated, :logical_used, :id, :nas_host
  attr_writer :logical_devices

  bytes_attr_accessor :size, :used, :free

  def logical_devices
    @logical_devices = [] unless @logical_devices
    @logical_devices
  end

  def total_logical_space_allocated
    @_total_logical_space_allocated ||= begin
                                          space = Bytes.new(0)
                                          logical_devices.each do |logical_device|
                                            space = space + logical_device.allocated
                                          end
                                          space
                                        end
  end

end
