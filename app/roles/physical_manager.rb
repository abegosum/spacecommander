module PhysicalManager

  def total_physical_space
    @_total_physical_space ||= begin
                                 space = Bytes.new(0)
                                 aggregates.each do |aggregate|
                                   space = space + aggregate.size
                                 end
                                 space
                               end
  end

  def total_physical_free_space
    @_total_physical_free_space ||= begin
                                      space = Bytes.new(0)
                                      aggregates.each do |aggregate|
                                        space = space + aggregate.free
                                      end
                                      space
                                    end
  end

  def total_physical_used_space
    @_total_physical_used_space ||= begin
                                      space = Bytes.new(0)
                                      aggregates.each do |aggregate|
                                        space = space + aggregate.used
                                      end
                                      space
                                    end
  end

end
