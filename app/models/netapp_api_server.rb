class NetappApiServer
  require 'netapp_sdk/NaServer'
  require 'netapp_sdk/NaElement'

  DEFAULT_SERVER_TYPE = 'FILER'
  DEFAULT_STYLE = 'LOGIN'
  DEFAULT_PORT = 443
  DEFAULT_TRANSPORT_TYPE = 'HTTPS'
  DEFAULT_API_MAJOR_VERSION = 1
  DEFAULT_API_MINOR_VERSION = 20
  API_LOOP_LIMIT = 20

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
    unless @na_server_instance
      @na_server_instance = NaServer.new host, 1, 20
      @na_server_instance.set_server_type server_type
      @na_server_instance.set_style style
      @na_server_instance.set_admin_user user, pass
      @na_server_instance.set_transport_type transport
      @na_server_instance.set_port port
    end
    @na_server_instance
  end

  def invoke_api method_name, *method_args
    puts "API CALL: #{method_name}"
    response = na_server_instance.invoke(method_name, *method_args)
    response
  end

  def invoke_api_or_fail method_name, *method_args
    response = invoke_api(method_name, *method_args)
    if response.results_status.eql? 'failed'
      raise RuntimeError.new "#{method_name} api call failed"
    end
    response
  end

  def is_7mode?
    if ! defined? @is_7mode
      puts "7 MODE NOT CACHED, test required"
      result = self.invoke_api 'system-get-info'
      @is_7mode = result.results_status.eql? 'passed'
    end
    @is_7mode
  end

  def is_cluster?
    if ! defined? @is_cluster
      puts "CLUSTER NOT CACHED, test required"
      if ! self.is_7mode?
        @is_cluster = ((self.invoke_api 'system-node-get-iter').results_status.eql? 'passed')
      else
        @is_cluster = false
      end
    end
    @is_cluster
  end

end
