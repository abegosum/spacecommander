class Netapp7modeNode < NetappApiServer
  include Filer, PhysicalManager

  SNAPSHOT_BLOCK_SIZE = 1024
  
  attr_accessor :partner_name, :partner, :id, :name, :partner_id, :model

  def initialize(host, init_user, init_pass)
    super
    unless is_7mode?
      raise IncorrectApiTypeError.new("#{host} appears not to be a 7-mode controller")
    end
    self.name = get_name_from_system_info
    self.id = get_id_from_system_info
    self.partner_name = get_partner_name_from_system_info
    self.partner_id = get_partner_id_from_system_info
    self.model = get_model_from_system_info
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

  def find_volume_by_id(id)
    result = nil
    volumes.each do |volume|
      result = volume if volume.id == id
      break if result
    end
    result
  end

  private
  def get_aggregates_from_aggr_space_info_array_element(aggregates_element)
    return [] unless aggregates_element
    aggregates_element.children_get.map do |aggregate_element|
      current_aggregate = Aggregate.new # TODO: Aggregate.create_from_aggr_space_info_element(element, volumes)
      current_aggregate.name = aggregate_element.child_get_string 'aggregate-name'
      current_aggregate.volume_used = aggregate_element.child_get_int 'size-volume-used'
      current_aggregate.used = aggregate_element.child_get_int 'size-used'
      current_aggregate.free = aggregate_element.child_get_int 'size-free'
      current_aggregate.allocated = aggregate_element.child_get_int 'size-volume-allocated'
      current_aggregate.metadata_size = aggregate_element.child_get_int 'size-metadata'
      current_aggregate.asis_used = aggregate_element.child_get_int 'size-asis-used'
      current_aggregate.size = aggregate_element.child_get_int 'size-nominal'
      current_aggregate.id = aggregate_id_hash[current_aggregate.name]
      volumes_element = aggregate_element.child_get('volumes')
      current_aggregate.volumes = get_volumes_from_volume_space_info_array_element volumes_element
      current_aggregate.node_host = host
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
        snapshot_reserve_blocks = volume_info_element.child_get_int 'snapshot-blocks-reserved'
        current_volume.snapshot_reserve = snapshot_reserve_blocks * SNAPSHOT_BLOCK_SIZE
        current_volume.containing_aggregate_name = volume_info_element.child_get_string 'containing-aggregate' 
        current_volume.containing_aggregate_uuid = aggregate_id_hash[current_volume.containing_aggregate_name]
        current_volume.id = volume_info_element.child_get_string 'uuid'
        current_volume.filer_host = host
        hsh[current_volume.name] = current_volume
        containing_aggregate = find_aggregate_by_name current_volume.containing_aggregate_name
        containing_aggregate.volumes << current_volume if containing_aggregate
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

  def aggregate_id_hash
    @_aggregate_id_hash ||= begin
                                result = {}
                                get_info_api_result = invoke_api_or_fail 'aggr-list-info'
                                aggr_infos_element = get_info_api_result.child_get 'aggregates'
                                if aggr_infos_element
                                  aggr_infos_element.children_get.each do |info_element|
                                    aggr_name = info_element.child_get_string 'name'
                                    result[aggr_name] = info_element.child_get_string 'uuid'
                                  end
                                end
                                result
                              end
  end

  def get_name_from_system_info
    @_system_info_element ||= invoke_api_or_fail('system-get-info').child_get 'system-info'
    @_system_info_element.child_get_string 'system-name'
  end

  def get_id_from_system_info
    @_system_info_element ||= invoke_api_or_fail('system-get-info').child_get 'system-info'
    @_system_info_element.child_get_string 'system-id'
  end

  def get_partner_name_from_system_info
    @_system_info_element ||= invoke_api_or_fail('system-get-info').child_get 'system-info'
    @_system_info_element.child_get_string 'partner-system-name'
  end

  def get_partner_id_from_system_info
    @_system_info_element ||= invoke_api_or_fail('system-get-info').child_get 'system-info'
    @_system_info_element.child_get_string 'partner-system-id'
  end

  def get_model_from_system_info
    @_system_info_element ||= invoke_api_or_fail('system-get-info').child_get 'system-info'
    @_system_info_element.child_get_string 'system-model'
  end

  def find_aggregate_by_name(aggregate_name)
    result = nil
    aggregates.each do |aggregate|
      result = aggregate if aggregate.name == aggregate_name
      break if result
    end
    result
  end

end
