class ApplicationController < ActionController::Base
  include NetappEnvironmentConsumer

  protect_from_forgery with: :exception
end
