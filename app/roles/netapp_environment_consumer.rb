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
# Mixin for controllers who need to access NetApp Environment information 
# inflated from netapp.yml.  See NetappEnvironment model for more information.
module NetappEnvironmentConsumer
  def netapp_environment
    @_netapp_environment ||= NetappEnvironment.new 
  end

end
