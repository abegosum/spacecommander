module Filer
  def total_volume_space_allocated
    @_total_volume_space_allocated ||= begin
                                         space = Bytes.new(0)
                                         volumes.each do |volume|
                                           space = space + volume.allocated
                                         end
                                         space
                                       end
  end

  def total_volume_space_used
    @_total_volume_space_used ||= begin
                                    space = Bytes.new(0)
                                    volumes.each do |volume|
                                      space = space + volume.used
                                    end
                                    space
                                  end
  end

  def total_volume_space_snapshot_reserve 
    @_total_volume_space_snapshot_reserve ||= begin
                                    space = Bytes.new(0)
                                    volumes.each do |volume|
                                      space = space + volume.snapshot_reserve
                                    end
                                    space
                                  end
  end

  def total_volume_space_free
    @_total_volume_space_free ||= begin
                                    space = Bytes.new(0)
                                    volumes.each do |volume|
                                      space = space + volume.available
                                    end
                                    space
                                  end
  end

end
