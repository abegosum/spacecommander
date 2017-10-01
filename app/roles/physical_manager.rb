#   Copyright 2017 Aaron M. Bond
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#
# Mixin representing a physical manager (NAS server that handles physical
# devices). Expects the aggregates member to be declared and to return an 
# array of the Aggregate model.
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

  def total_volume_space_allocated
    @_total_volume_space_allocated ||= begin
                                         space = Bytes.new(0)
                                         all_volumes.each do |volume|
                                           space = space + volume.allocated
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

  private

  def all_volumes
    @_all_volumes ||= begin
                        all_volumes = []
                        aggregates.each do |aggregate|
                          all_volumes.concat aggregate.volumes
                        end
                        all_volumes
                      end
  end

end
