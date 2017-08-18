class Netapp7modeNode < NetappApiServer
  SNAPSHOT_BLOCK_SIZE = 1024

  def initialize(host, init_user, init_pass)
    super
    unless is_7mode?
      raise IncorrectApiTypeError.new("#{host} appears not to be a 7-mode controller")
    end
  end

  def aggregates(force_refresh=false)
    if !@_aggregates || force_refresh
      @_aggregates = []
      api_result = invoke_api_or_fail 'aggr-space-list-info'
      aggregates_element = api_result.child_get('aggregates')
      @_aggregates = get_aggregates_from_aggr_space_info_array_element aggregates_element
    end
    @_aggregates
  end

  def volumes(force_refresh=false)
    hash = volume_info_hash force_refresh
    hash.values
  end

  private
  def get_aggregates_from_aggr_space_info_array_element(aggregates_element)
    return [] unless aggregates_element
    aggregates_element.children_get.map do |aggregate_element|
      current_aggregate = Aggregate.new # TODO: Aggregate.create_from_aggr_space_info_element(element, volumes)
      current_aggregate.name = aggregate_element.child_get_string 'aggregate-name'
      current_aggregate.volume_used = aggregate_element.child_get_int 'size-volume-used'
      current_aggregate.used = aggregate_element.child_get_int 'used'
      current_aggregate.free = aggregate_element.child_get_int 'size-free'
      current_aggregate.allocated = aggregate_element.child_get_int 'size-volume-allocated'
      current_aggregate.metadata_size = aggregate_element.child_get_int 'size-metadata'
      current_aggregate.asis_used = aggregate_element.child_get_int 'size-asis-used'
      current_aggregate.size = aggregate_element.child_get_int 'size-nominal'
      volumes_element = aggregate_element.child_get('volumes')
      current_aggregate.volumes = get_volumes_from_volume_space_info_array_element volumes_element
      current_aggregate
    end
  end

  def get_volumes_from_volume_space_info_array_element(volumes_element)
    return [] unless volumes_element
    volumes_element.children_get.map do |volume_space_info|
      volume_info_hash[volume_space_info.child_get_string('volume-name')]
    end
  end

  def volume_info_hash(force_refresh=false)
    @_volume_info_hash = nil if force_refresh
    @_volume_info_hash ||= begin
      get_volume_info_element_array.inject({}) do |hsh, volume_info_element|
        current_volume = Volume.new # Volume.create_from_volume_info(volume_info)
        current_volume.name = volume_info_element.child_get_string 'name' 
        current_volume.allocated = volume_info_element.child_get_int 'filesystem-size'
        current_volume.used = volume_info_element.child_get_int 'size-used'
        current_volume.available = volume_info_element.child_get_int 'size-available'
        snapshot_reserve_blocks = volume_info_element.child_get_int 'snapshot-blocks-reserve'
        current_volume.snapshot_reserve = snapshot_reserve_blocks * SNAPSHOT_BLOCK_SIZE
        current_volume.containing_aggregate_name = volume_info_element.child_get_string 'containing-aggregate' 
        current_volume.id = volume_info_element.child_get_string 'uuid'
        hsh[current_volume.name] = current_volume
        hsh
      end
    end
  end

  def get_volume_info_element_array 
    @_volume_info_element_array = []
    start_api_result = invoke_api_or_fail 'volume-list-info-iter-start'
    tag = start_api_result.child_get_string 'tag'
    records = start_api_result.child_get_int 'records'
    while records > 0 && (loop_iter ||= 0) < API_LOOP_LIMIT
      api_result = invoke_api_or_fail 'volume-list-info-iter-next', 'tag', tag, 'maximum', LEGACY_API_MAX_RESULTS
      records = api_result.child_get_int 'records'
      volumes_element = api_result.child_get 'volumes'
      @_volume_info_element_array.concat volumes_element.children_get if volumes_element
      loop_iter += 1
    end
    invoke_api_or_fail 'volume-list-info-iter-end', 'tag', tag
    @_volume_info_element_array
  end

end
