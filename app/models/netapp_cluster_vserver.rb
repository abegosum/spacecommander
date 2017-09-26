class NetappClusterVserver < NetappApiServer
  include Filer

  def initialize(host, init_user, init_pass)
    super
    if is_cluster?
      raise IncorrectApiTypeError.new("#{host} appears to be a cluster VIF and cannot be initialized as a vserver")
    end
    if is_7mode?
      raise IncorrectApiTypeError.new("#{host} appears to be a 7-mode controller and cannot be initialized as a vserver")
    end
  end

  def id
    @_id ||= get_vserver_info_element.child_get_string 'uuid'
  end

  def aggregate_names
    volumes.map(&:containing_aggregate_name).uniq
  end

  def volumes(force_refresh=false)
    if (! @_volumes) || force_refresh
      @_volumes = []
      # rebuild the aggregate names hash
      @aggregate_names_hash = {}
      api_response = invoke_api_or_fail 'volume-get-iter'
      next_tag = api_response.child_get_string 'next-tag'
      attributes_list_element = api_response.child_get 'attributes-list'
      volumes.concat get_volumes_from_volume_attributes_array_element(attributes_list_element)
      while next_tag && (loop_iter ||= 0) < API_LOOP_LIMIT
        api_response = invoke_api_or_fail 'volume-get-iter', 'tag', next_tag
        next_tag = api_response.child_get_string 'next-tag'
        attributes_list_element = api_response.child_get 'attributes-list'
        volumes.concat get_volumes_from_volume_attributes_array_element(attributes_list_element)
        loop_iter += 1
      end
    end
    @_volumes
  end

  private
  def get_volumes_from_volume_attributes_array_element(volumes_element)
    return [] unless volumes_element
    volumes_element.children_get.map do |volume_attributes| 
      volume_id_attributes = volume_attributes.child_get 'volume-id-attributes'
      volume_space_attributes = volume_attributes.child_get 'volume-space-attributes'
      current_volume = Volume.new #TODO: Volume.create_from_attributes(volume_attributes)
      current_volume.name = volume_id_attributes.child_get_string 'name'
      current_volume.allocated = volume_space_attributes.child_get_int 'filesystem-size'
      current_volume.used = volume_space_attributes.child_get_int 'size-used'
      current_volume.available = volume_space_attributes.child_get_int 'size-available'
      current_volume.snapshot_reserve = volume_space_attributes.child_get_int 'snapshot-reserve-size'
      current_volume.size_used_by_snapshots = volume_space_attributes.child_get_int 'size-used-by-snapshots'
      current_volume.containing_aggregate_name = volume_id_attributes.child_get_string 'containing-aggregate-name'
      current_volume.containing_aggregate_uuid = volume_id_attributes.child_get_string 'containing-aggregate-uuid'
      current_volume.id = volume_id_attributes.child_get_string 'instance-uuid'
      current_volume.filer_host = host
      current_volume
    end 
  end

  def get_vserver_info_element
    @_vserver_info_element ||= invoke_api_or_fail('vserver-get').child_get('attributes').child_get('vserver-info')
  end

end
