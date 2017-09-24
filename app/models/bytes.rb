class Bytes
  CONVERSION_FACTOR = 1024.0

  def initialize size
    @byte_size = size
  end

  def +(val)
    self.class.new(@byte_size + val.to_i) #val may be bytes class, coerce to i
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
    if to_b <= CONVERSION_FACTOR
      result = sprintf "%0.02f B", to_b
    elsif to_mb <= CONVERSION_FACTOR
      result = sprintf "%0.02f MB", to_mb
    elsif to_gb <= CONVERSION_FACTOR
      result = sprintf "%0.02f GB", to_gb
    elsif to_tb <= CONVERSION_FACTOR
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
