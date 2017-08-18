class Netapp7modeNode < NetappApiServer
  SNAPSHOT_BLOCK_SIZE = 1024

  def initialize host, init_user, init_pass
    super host, init_user, init_pass
    if ! is_7mode?
      raise ArgumentError.new("#{host} appears not to be a 7-mode controller")
    end
  end

  def aggregates force_refresh=false
    if (! @aggregates) || force_refresh
      @aggregates = []
      api_result = invoke_api_or_fail 'aggr-space-list-info'
      aggregates_element = api_result.child_get('aggregates')
      @aggregates = get_aggregates_from_aggr_space_info_array_element aggregates_element
    end #unless
    @aggregates
  end

  def volumes force_refresh=false
    hash = volume_info_hash force_refresh
    hash.values
  end

  private
  def get_aggregates_from_aggr_space_info_array_element aggregates_element
    aggregates = []
    if aggregates_element
      aggregates_element.children_get.each do |aggregate_element|
        current_aggregate = Aggregate.new
        current_aggregate.name = aggregate_element.child_get_string 'aggregate-name'
        current_aggregate.used = aggregate_element.child_get_int 'size-used'
        current_aggregate.free = aggregate_element.child_get_int 'size-free'
        aggr_volumes = []
        volumes_element = aggregate_element.child_get('volumes')
        current_aggregate.volumes = get_volumes_from_volume_space_info_array_element volumes_element, current_aggregate.name
        aggregates << current_aggregate
      end
    end 
    aggregates
  end

  def get_volumes_from_volume_space_info_array_element volumes_element, aggregate_name=nil
    volumes = []
    if volumes_element
      volume_space_info_elements = volumes_element.children_get
    else 
      volume_space_info_elements = []
    end
    volume_space_info_elements.each do |volume_space_info|
      name = volume_space_info.child_get_string 'volume-name'
      volumes << volume_info_hash[name]
    end #volue loop
    volumes
  end

  def volume_info_hash force_refresh=false
    if (! @volume_info_hash) || force_refresh
      @volume_info_hash = {}
      volume_info_elements = get_volume_info_element_array 
      volume_info_elements.each do |volume_info_element|
        name = volume_info_element.child_get_string 'name'
        current_volume = Volume.new
        current_volume.name = name
        current_volume.allocated = volume_info_element.child_get_int 'filesystem-size'
        current_volume.used = volume_info_element.child_get_int 'size-used'
        current_volume.available = volume_info_element.child_get_int 'size-available'
        snapshot_reserve_blocks = volume_info_element.child_get_int 'snapshot-blocks-reserve'
        current_volume.snapshot_reserve = snapshot_reserve_blocks * SNAPSHOT_BLOCK_SIZE
        current_volume.containing_aggregate_name = volume_info_element.child_get_string 'containing-aggregate' 
        current_volume.id = volume_info_element.child_get_string 'uuid'
        @volume_info_hash[name] = current_volume
      end
    end
    @volume_info_hash
  end

  def get_volume_info_element_array 
    @volume_info_element_array = []
    api_result = invoke_api_or_fail 'volume-list-info-iter-start'
    tag = api_result.child_get_string 'tag'
    records = api_result.child_get_int 'records'
    loop_iter = 0
    while records > 0 && loop_iter < API_LOOP_LIMIT
      api_result = invoke_api_or_fail 'volume-list-info-iter-next', 'tag', tag, 'maximum', LEGACY_API_MAX_RESULTS
      records = api_result.child_get_int 'records'
      volumes_element = api_result.child_get 'volumes'
      @volume_info_element_array.concat volumes_element.children_get if volumes_element
      loop_iter += 1
    end
    invoke_api_or_fail 'volume-list-info-iter-end', 'tag', tag
    @volume_info_element_array
  end

end
