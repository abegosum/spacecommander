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

  def total_physical_space_free
    @_total_physical_space_free ||= begin
                                      space = Bytes.new(0)
                                      aggregates.each do |aggregate|
                                        space = space + aggregate.free
                                      end
                                      space
                                    end
  end

  def total_physical_space_used
    @_total_physical_space_used ||= begin
                                      space = Bytes.new(0)
                                      aggregates.each do |aggregate|
                                        space = space + aggregate.used
                                      end
                                      space
                                    end
  end

  def find_aggregate_by_name(name)
    result = nil
    aggregates.each do |aggregate|
      result = aggregate if aggregate.name == name
      break if result
    end
    result
  end

end
