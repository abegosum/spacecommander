class EnvironmentController < ApplicationController
  include NetappEnvironmentConsumer

  def refresh
    netapp_environment.reset_all_data
    flash[:global_message] = "Cached data cleared."
    respond_to do |format|
      format.html { redirect_to :controller => :locations, :action => :index }
      format.json { render :json => true }
    end
  end
end
