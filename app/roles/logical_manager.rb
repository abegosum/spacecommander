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
# Mixin representing a filer (NAS server that handles logical devices).
# Expects the volumes member to be declared and to return an array of 
# the Volume model.
module LogicalManager
  def total_logical_device_space_allocated
    @_total_logical_device_space_allocated ||= begin
                                         space = Bytes.new(0)
                                         logical_devices.each do |logical_device|
                                           space = space + logical_device.allocated
                                         end
                                         space
                                       end
  end

  def total_logical_device_space_used
    @_total_logical_device_space_used ||= begin
                                    space = Bytes.new(0)
                                    logical_devices.each do |logical_device|
                                      space = space + logical_device.used
                                    end
                                    space
                                  end
  end

  def total_logical_device_space_free
    @_total_logical_device_space_free ||= begin
                                    space = Bytes.new(0)
                                    logical_devices.each do |logical_device|
                                      space = space + logical_device.available
                                    end
                                    space
                                  end
  end

  def find_logical_device_by_id(id)
    result = nil
    logical_devices.each do |logical_device|
      result = logical_device if logical_device.id == id
      break if result
    end
    result
  end

  def find_logical_device_by_name(name)
    result = nil
    logical_devices.each do |logical_device|
      result = logical_device if logical_device.name == name
      break if result
    end
    result
  end
end
