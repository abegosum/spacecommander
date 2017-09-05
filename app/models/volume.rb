class Volume
  extend Byteable

  attr_accessor :name, :containing_aggregate_name, :id
  bytes_attr_accessor :allocated, :used, :available, :snapshot_reserve, :size_used_by_snapshots
end
