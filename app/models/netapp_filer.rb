class NetappFiler < NetappApiServer

  
  def initialize host, init_user, init_pass
    super host, init_user, init_pass
    if is_cluster?
      raise ArgumentError.new("#{host} appears to be a cluster VIF and cannot be initialized as a filer")
    end
  end

  def aggregates_7mode force_refresh=false
    if ! is_7mode?
      raise ArgumentError.new('Attempt to retrieve aggregates using 7-mode API in Cluster Mode')
    end
    unless @aggregates_7mode || force_refresh
      @aggregates_7mode = []
      api_result = invoke_api_or_fail 'aggr-space-list-info'
      aggregates_element = api_result.child_get('aggregates')
      @aggregates_7mode = get_aggregates_from_aggr_space_info_array_element aggregates_element
    end #unless
    @aggregates_7mode
  end


  def volumes force_refresh=false
    unless @volumes || force_refresh
      if is_7mode?
        @volumes = get_volumes_7mode
      else 
        @volumes = get_volumes_clustered
      end
    end
    @volumes
  end

  private

  def get_volumes_clustered
    if is_7mode?
      raise ArgumentError.new('Attempt to retrieve volumes using Cluster API in 7-Mode')
    end
    volumes = []
    api_response = invoke_api_or_fail 'volume-get-iter'
    next_tag = api_response.child_get_string 'next-tag'
    attributes_list_element = api_response.child_get 'attributes-list'
    volumes.concat get_volumes_from_volume_attributes_array_element(attributes_list_element)
    loop_iter = 0
    while next_tag && loop_iter < API_LOOP_LIMIT
      api_response = invoke_api_or_fail 'volume-get-iter', 'tag', next_tag
      next_tag = api_response.child_get_string 'next-tag'
      attributes_list_element = api_response.child_get 'attributes-list'
      volumes.concat get_volumes_from_volume_attributes_array_element(attributes_list_element)
      loop_iter += 1
    end
    volumes
  end
  
  def get_aggregates_from_aggr_space_info_array_element aggregates_element
    aggregates = []
    if aggregates_element
      aggregates_element.children_get.each do |aggregate_element|
        current_aggregate = Aggregate.new
        current_aggregate.name = aggregate_element.child_get_string 'aggregate-name'
        current_aggregate.used = aggregate_element.child_get_int 'size-used'
        current_aggregate.free = aggregate_element.child_get_int 'size-free'
        puts current_aggregate
        aggr_volumes = []
        volumes_element = aggregate_element.child_get('volumes')
        current_aggregate.volumes = get_volumes_from_volume_space_info_array_element volumes_element, current_aggregate.name
        aggregates << current_aggregate
      end
    end 
    aggregates
  end

  def get_volumes_from_volume_attributes_array_element volumes_element
    volumes = []
    if volumes_element
      volume_attributes_elements = volumes_element.children_get
    else
      volume_attributes_elements = []
    end
    volume_attributes_elements.each do |volume_attributes|
      volume_id_attributes = volume_attributes.child_get 'volume-id-attributes'
      volume_space_attributes = volume_attributes.child_get 'volume-space-attributes'
      current_volume = Volume.new
      current_volume.name = volume_id_attributes.child_get_string 'name'
      current_volume.allocated = volume_space_attributes.child_get_int 'filesystem-size'
      current_volume.used = volume_space_attributes.child_get_int 'size-used'
      current_volume.available = volume_space_attributes.child_get_int 'size-available'
      current_volume.snapshot_reserve = volume_space_attributes.child_get_int 'snapshot-reserve-size'
      current_volume.size_used_by_snapshots = volume_space_attributes.child_get_int 'size-used-by-snapshots'
      current_volume.containing_aggregate_name = volume_id_attributes.child_get_string 'containing-aggregate-name'
      current_volume.id = volume_id_attributes.child_get_string 'instance-uuid'
      volumes << current_volume
    end
    volumes
  end

  def get_volumes_from_volume_space_info_array_element volumes_element, aggregate_name=nil
    volumes = []
    if volumes_element
      volume_space_info_elements = volumes_element.children_get
    else 
      volume_space_info_elements = []
    end
    volume_space_info_elements.each do |volume_space_info|
      current_volume = Volume.new
      current_volume.name = volume_space_info.child_get_string 'volume-name'
      current_volume.allocated = volume_space_info.child_get_int 'volume-allocated'
      current_volume.used = volume_space_info.child_get_int 'volume-used'
      current_volume.containing_aggregate_name = aggregate_name if aggregate_name
      volumes << current_volume
    end #volue loop
    volumes
  end

  def get_volumes_7mode force_refresh=false
    if ! is_7mode?
      raise ArgumentError.new('Attempt to retrieve volumes using 7-mode API in Cluster Mode')
    end
    volumes = []
    aggregates_7mode.each do |aggregate|
      volumes.concat aggregate.volumes
    end
    volumes
  end
end
