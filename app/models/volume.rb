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
# Represents a logical volume on a NetApp.
class Volume < LogicalDevice
  extend Byteable

  bytes_attr_accessor :snapshot_reserve, :size_used_by_snapshots, :logical_used

  alias :containing_aggregate_name :containing_physical_device_name
  alias :containing_aggregate_name= :containing_physical_device_name=

  alias :containing_aggregate_uuid :containing_physical_device_uuid
  alias :containing_aggregate_uuid= :containing_physical_device_uuid=

end
