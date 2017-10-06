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
require 'faraday'
require 'json'

class FreeNasApiClient < NasServer
  
  DEFAULT_API_VERSION = 'v1.0'

  attr_accessor :api_server, :user, :pass, :protocol, :port, :api_version

  def initialize api_server, user, pass, protocol = 'https'
    self.api_server = api_server
    self.user = user
    self.pass = pass
    self.protocol = protocol
    self.api_version = DEFAULT_API_VERSION
  end

  def nas_type
    "FreeNas"
  end

  def physical_device_label(plural = false)
    if plural
      "Volumes"
    else
      "Volume"
    end
  end

  def logical_device_label(plural = false)
    if plural
      "Datasets"
    else
      "Dataset"
    end
  end

  def base_api_path
    "/api/#{api_version}"
  end

  def base_storage_api_path
    "#{base_api_path}/storage"
  end

  def base_fnvolume_api_path
    "#{base_storage_api_path}/volume"
  end

  def http_faraday_connection
    @_http_faraday_connection ||= Faraday.new(:url => "#{protocol}://#{api_server}") do |connection|
      connection.basic_auth(user, pass)
      connection.ssl.verify = false
      connection.adapter Faraday.default_adapter
    end
  end

end
