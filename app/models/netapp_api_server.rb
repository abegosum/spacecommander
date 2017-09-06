require 'netapp_sdk/NaServer'
require 'netapp_sdk/NaElement'

class NetappApiServer

  DEFAULT_SERVER_TYPE = 'FILER'
  DEFAULT_STYLE = 'LOGIN'
  DEFAULT_PORT = 443
  DEFAULT_TRANSPORT_TYPE = 'HTTPS'
  DEFAULT_API_MAJOR_VERSION = 1
  DEFAULT_API_MINOR_VERSION = 20
  API_LOOP_LIMIT = 20
  LEGACY_API_MAX_RESULTS = 20
  API_MISSING_ERRNO = 13005

  attr_accessor :host, :user, :pass, :server_type, :transport, :style, :port, :api_major_version, :api_minor_version

  def initialize host, init_user, init_pass
    self.host = host
    self.user = init_user
    self.pass = init_pass
    self.api_major_version = DEFAULT_API_MAJOR_VERSION
    self.api_minor_version = DEFAULT_API_MINOR_VERSION
    self.server_type = DEFAULT_SERVER_TYPE
    self.style = DEFAULT_STYLE
    self.transport = DEFAULT_TRANSPORT_TYPE
    self.port = DEFAULT_PORT
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
    puts "API CALL: #{method_name}"
    response = na_server_instance.invoke(method_name, *method_args)
    response
  end

  def invoke_api_or_fail(method_name, *method_args)
    response = invoke_api(method_name, *method_args)
    if response.results_status == 'failed'
      raise RuntimeError.new "#{method_name} api call failed: #{response.results_reason}"
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
