class FilersController < ApplicationController
  before_action :set_netapp_environment, only: [ :view ] # fire this callback before processing show action

  def list
  end

  def view
    @filer = @netapp_environment.find_filer_by_name params[:filername]
  end

  private
  def set_netapp_environment
    @netapp_environment = NetappEnvironment.new
  end
end
