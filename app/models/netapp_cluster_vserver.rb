class NetappClusterVserver < NetappApiServer

  def initialize host, init_user, init_pass
    super host, init_user, init_pass
    if is_cluster?
      raise ArgumentError.new("#{host} appears to be a cluster VIF and cannot be initialized as a vserver")
    end
    if is_7mode?
      raise ArgumentError.new("#{host} appears to be a 7-mode controller and cannot be initialized as a vserver")
    end
  end

  def aggregate_names force_refresh=false
    if (! @aggregate_names_hash) || force_refresh
      volumes force_refresh
    end
    @aggregate_names_hash.values
  end

  def volumes force_refresh=false
    if (! @volumes) || force_refresh
      @volumes = []
      # rebuild the aggregate names hash
      @aggregate_names_hash = {}
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
    end
    @volumes
  end

  private
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
      @aggregate_names_hash[current_volume.containing_aggregate_name] = current_volume.containing_aggregate_name if @aggregate_names_hash
      volumes << current_volume
    end
    volumes
  end
end
