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
require 'netapp_sdk/NaServer'
require 'netapp_sdk/NaElement'
require 'thread'

# Represents any server that can respond to the NetApp managability API.
# This relies on the ruby classes from the NetApp Manageability SDK found
# here: https://community.netapp.com/t5/Software-Development-Kit-SDK-and-API-Discussions/NetApp-Manageability-NM-SDK-5-4-Introduction-and-Download-Information/td-p/108181
# Ensure that the .rb files are extracted and placed in the lib/ folder 
# of this project
class NetappApiServer < NasServer

  DEFAULT_SERVER_TYPE = 'FILER'
  DEFAULT_STYLE = 'LOGIN'
  DEFAULT_PORT = 443
  DEFAULT_TRANSPORT_TYPE = 'HTTPS'
  DEFAULT_API_MAJOR_VERSION = 1
  DEFAULT_API_MINOR_VERSION = 20
  API_LOOP_LIMIT = 20
  LEGACY_API_MAX_RESULTS = 20
  API_MISSING_ERRNO = 13005

  attr_accessor :host, :user, :pass, :server_type, :transport, :style, :port, :api_major_version, :api_minor_version, :location

  # I know, I know, "Mutex?  Semaphore?  What the hell?"
  # Turns out, NetApp, in designing their ruby SDK decided
  # to use globals in their element parsing.  This means that
  # multiple calls to NaServer.invoke will intermingle the results
  # leading to hilarious errors.  This mutex is used when making 
  # API calls to ensure that they are all thread safe, even though
  # the underlying code is not.  Slows things down a bit; but, we cache,
  # so we only feel the pain on cache miss.  Sorry guys, but
  # I don't have any control over the piece of code that's causing
  # this need.
  @@na_server_semaphore = Mutex.new

  def initialize host, init_user, init_pass
    self.host = host.to_s
    self.user = init_user.to_s
    self.pass = init_pass.to_s
    self.api_major_version = DEFAULT_API_MAJOR_VERSION
    self.api_minor_version = DEFAULT_API_MINOR_VERSION
    self.server_type = DEFAULT_SERVER_TYPE
    self.style = DEFAULT_STYLE
    self.transport = DEFAULT_TRANSPORT_TYPE
    self.port = DEFAULT_PORT
  end

  def nas_type
    "NetApp"
  end

  def physical_device_label(plural = false)
    if plural
      "Aggregates"
    else
      "Aggregate"
    end
  end

  def logical_device_label(plural = false)
    if plural
      "Volumes"
    else
      "Volume"
    end
  end

  def na_server_instance
    @_na_server_instance ||= begin
      @_na_server_instance = NaServer.new host, api_major_version, api_minor_version
      @_na_server_instance.set_server_type server_type
      @_na_server_instance.set_style style
      @_na_server_instance.set_admin_user user, pass
      @_na_server_instance.set_transport_type transport
      @_na_server_instance.set_port port
      @_na_server_instance
    end
  end

  def invoke_api(method_name, *method_args)
    @@na_server_semaphore.synchronize {
      puts "API CALL: #{method_name} (#{host})" unless Rails.env.production?
      response = na_server_instance.invoke(method_name, *method_args)
      response
    }
  end

  def invoke_api_or_fail(method_name, *method_args)
    response = invoke_api(method_name, *method_args)
    if response.results_status == 'failed'
      raise RuntimeError.new "#{method_name} api call failed against #{host}: #{response.results_reason}"
    end
    response
  end

  def version
    @_version ||= begin
                    system_version_element = get_system_version_element
                    @_version = system_version_element.child_get_string 'version'
                  end
  end

  def is_7mode?
    unless defined? @_is_7mode
      system_version_element = get_system_version_element
      @_is_7mode = system_version_element.child_get_string('is-clustered') == 'false'
    end
    @_is_7mode
  end

  def is_cluster?
    unless defined? @_is_cluster
      @_is_cluster = if ! is_7mode?
                       invoke_api('system-node-get-iter').results_status == 'passed'
                     else
                       false
                     end
    end
    @_is_cluster
  end

  def instance_type
    if is_7mode?
      :netapp_7mode_node
    elsif is_cluster?
      :netapp_cluster_vif
    else 
      :netapp_cluster_vserver
    end
  end

  def self.create_instance(host, user, pass)
    api_server = new(host, user, pass)
    case api_server.instance_type
    when :netapp_7mode_node
      Netapp7modeNode.new host, user, pass
    when :netapp_cluster_vif
      NetappApiServer.new host, user, pass
    when :netapp_cluster_vserver
      NetappClusterVserver.new host, user, pass
    else
      api_server
    end
  end

  class IncorrectApiTypeError < StandardError; end

  private
  def get_system_version_element
    @_system_version_element ||= self.invoke_api_or_fail 'system-get-version'
  end

end
