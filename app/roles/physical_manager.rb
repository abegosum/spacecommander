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
# Mixin representing a physical manager (NAS server that handles physical
# devices). Expects the physical_devices member to be declared and to return an 
# array of the Aggregate model.
module PhysicalManager

  def total_physical_space
    @_total_physical_space ||= begin
                                 space = Bytes.new(0)
                                 physical_devices.each do |physical_device|
                                   space = space + physical_device.size
                                 end
                                 space
                               end
  end

  def total_physical_space_free
    @_total_physical_space_free ||= begin
                                      space = Bytes.new(0)
                                      physical_devices.each do |physical_device|
                                        space = space + physical_device.free
                                      end
                                      space
                                    end
  end

  def total_physical_space_used
    @_total_physical_space_used ||= begin
                                      space = Bytes.new(0)
                                      physical_devices.each do |physical_device|
                                        space = space + physical_device.used
                                      end
                                      space
                                    end
  end

  def total_volume_space_allocated
    @_total_volume_space_allocated ||= begin
                                         space = Bytes.new(0)
                                         all_logical_devices.each do |logical_device|
                                           space = space + logical_device.allocated
                                         end
                                         space
                                       end
  end

  def find_physical_device_by_name(name)
    result = nil
    physical_devices.each do |physical_device|
      result = physical_device if physical_device.name == name
      break if result
    end
    result
  end

  private

  def all_logical_devices
    @_all_logical_devices ||= begin
                                all_logical_devices = []
                                physical_devices.each do |physical_device|
                                  all_logical_devices.concat physical_device.logical_devices
                                end
                                all_logical_devices
                              end
  end

end
