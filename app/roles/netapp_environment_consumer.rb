module NetappEnvironmentConsumer
  def netapp_environment
    @_netapp_environment ||= NetappEnvironment.new 
  end

end
