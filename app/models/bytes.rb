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
# Represents numeric extension to allow for easy byte calculation and display.
class Bytes
  include Comparable

  CONVERSION_FACTOR = 1024.0

  def initialize size
    @byte_size = size
  end

  def +(val)
    self.class.new(@byte_size + val.to_i) #val may be bytes class, coerce to i
  end

  def -(val)
    self.class.new(@byte_size - val.to_i) #val may be bytes class, coerce to i
  end

  def <=>(other)
    to_i <=> other.to_i
  end

  def abs
    self.class.new(@byte_size.abs)
  end

  def to_b
    @byte_size
  end

  def to_kb
    to_b / CONVERSION_FACTOR
  end

  def to_mb
    to_kb / CONVERSION_FACTOR
  end

  def to_gb
    to_mb / CONVERSION_FACTOR
  end

  def to_tb
    to_gb / CONVERSION_FACTOR
  end

  def to_pb
    to_tb / CONVERSION_FACTOR
  end

  def to_i
    to_b
  end

  def to_human_readable_s
    result = @byte_size.to_s
    if to_b < CONVERSION_FACTOR
      result = sprintf "%0.02f B", to_b
    elsif to_mb < CONVERSION_FACTOR
      result = sprintf "%0.02f MB", to_mb
    elsif to_gb < CONVERSION_FACTOR
      result = sprintf "%0.02f GB", to_gb
    elsif to_tb < CONVERSION_FACTOR
      result = sprintf "%0.02f TB", to_tb
    else
      result = sprintf "%0.02f PB", to_pb
    end
    result
  end

  def to_s
    to_human_readable_s
  end
end
