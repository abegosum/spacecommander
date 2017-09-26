module NetappEnvironmentConsumer
  def netapp_environment
    @_netapp_environment ||= NetappEnvironment.new unless @netapp_environment
  end

end
