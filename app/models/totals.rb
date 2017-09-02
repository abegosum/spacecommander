class Totals

  attr_accessor :physical_provisioned, :physical_used, :physical_available, :volume_provisioned, :volume_used, :volume_available


  def initialize
    self.physical_provisioned = 0
    self.physical_used = 0
    self.physical_available = 0
    self.volume_provisioned = 0
    self.volume_used = 0
    self.volume_available = 0
  end
end
