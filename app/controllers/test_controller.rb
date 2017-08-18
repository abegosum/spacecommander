class TestController < ApplicationController
  def view

    require 'netapp_sdk/NaServer'

    @hostname = 'hqvna01.mpr.org'
    @user = 'root'
    @pass = 'k1jHJehU'
    @serverType = 'FILER'
    @transportType = 'HTTPS'

    @server = NaServer.new(@hostname, 1, 20)
    @server.set_server_type(@serverType)
    @server.set_transport_type(@transportType)
    @server.set_style("LOGIN")
    @server.set_admin_user(@user, @pass)
    @response = @server.invoke('volume-get-iter')
    binding.pry
    @initialResponseXml = @response.sprintf
    @nextTag = @response.child_get_string('next-tag')
    @volumesObject = @response.children_get()[0]
    @volumesXml = @volumesObject.sprintf
    @volumesDoc = Nokogiri::XML(@volumesXml)

    @allVolsResults = []

    @iterSafety = 0

    @iterMax = 10

    while @nextTag
      @allVolsResults.push @volumesDoc
      @response = @server.invoke('volume-get-iter', 'tag', @nextTag)
      @nextTag = @response.child_get_string('next-tag')
      puts "nextTag: #{@nextTag}"
      puts "iterator: #{@iterSafety}"
      @volumesObject = @response.children_get()[0]
      @volumesXml = @volumesObject.sprintf
      @volumesDoc = Nokogiri::XML(@volumesXml)
      @iterSafety = @iterSafety + 1
      if @iterSafety >= @iterMax
        break
      end
    end

    @allVolsResults.push @volumesDoc
  end
end
