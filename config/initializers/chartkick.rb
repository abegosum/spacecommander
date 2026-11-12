Rails.application.config.to_prepare do
  Chartkick.options = {
    colors: ChartHandler.colors
  }
end
