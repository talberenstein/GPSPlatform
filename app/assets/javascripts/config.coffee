newGeoZoneMap =
  domId: 'geozones_new_map'
  initialPosition: [-33.449559, -70.671239] # Santiago de Chile
  initialZoom: 13
  minZoom: 7

editGeoZoneMap =
  domId: 'geozones_edit_map'
  initialPosition: [-33.449559, -70.671239] # Santiago de Chile
  initialZoom: 13
  minZoom: 7

newMap = editMap = newDrawnItems = editDrawnItems = null

initNewGeoZoneMap = ->
  return if $("#"+newGeoZoneMap.domId).length == 0
  ######## Inicializar el mapa con las capas de Open Street Maps ############
  newMap = L.map(newGeoZoneMap.domId, {minZoom: newGeoZoneMap.minZoom, worldCopyJump: true}).setView(newGeoZoneMap.initialPosition, newGeoZoneMap.initialZoom)
  osmUrl='http://{s}.tile.openstreetmap.se/hydda/full/{z}/{x}/{y}.png'
  osmAttrib=''
  osm = new L.TileLayer(osmUrl, {attributionControl: false})
  newMap.addLayer(osm)

  newDrawnItems = L.geoJson(
    [],
    style: (feature) ->
      color: feature.geometry.properties.color
    onEachFeature: (feature, layer) ->
        layer.bindPopup(feature.properties.name);
  ).addTo(newMap)

  drawControlFull = new L.Control.Draw(
    edit:
      featureGroup: newDrawnItems
      poly: allowIntersection: false
    draw:
      circle: false
      polyline: false
      polygon: false
      rectangle:
        shapeOptions:
          color: '#0000ff'
  )

  drawControlEditOnly = new L.Control.Draw(
    edit: featureGroup: newDrawnItems
    draw: false
  )

  newMap.addControl(drawControlFull)

  newMap.on "draw:created", (e) =>
    layer = e.layer;
    layer.addTo(newDrawnItems);
    newMap.removeControl(drawControlFull)
    newMap.addControl(drawControlEditOnly)
    $('#new_geo_zone_geom').val(JSON.stringify(layer.toGeoJSON()))
    console.log "JSON: "+JSON.stringify(layer.toGeoJSON())

  newMap.on "draw:edited", (e) =>
    $('#new_geo_zone_geom').val(JSON.stringify(e.layer.toGeoJSON()))

  newMap.on "draw:deleted", (e) =>
    check = Object.keys(newDrawnItems._layers).length
    if (check == 0)
      newMap.removeControl(drawControlEditOnly)
      newMap.addControl(drawControlFull)
      $('#new_geo_zone_geom').removeAttr('value')

initEditGeoZoneMap = ->
  return if $("#"+editGeoZoneMap.domId).length == 0
  ######## Inicializar el mapa con las capas de Open Street Maps ############
  editMap = L.map(editGeoZoneMap.domId, {minZoom: editGeoZoneMap.minZoom, worldCopyJump: true}).setView(editGeoZoneMap.initialPosition, editGeoZoneMap.initialZoom)
  osmUrl='http://{s}.tile.openstreetmap.se/hydda/full/{z}/{x}/{y}.png'
  osmAttrib=''
  osm = new L.TileLayer(osmUrl, {attributionControl: false})
  editMap.addLayer(osm)

  editDrawnItems = L.geoJson(
    [],
    style: (feature) ->
      color: feature.geometry.properties.color
    onEachFeature: (feature, layer) ->
        layer.bindPopup(feature.properties.name);
  ).addTo(editMap)

  drawControlFull = new L.Control.Draw(
    edit:
      featureGroup: editDrawnItems
      poly: allowIntersection: false
    draw:
      circle: false
      polyline: false
      rectangle:
        shapeOptions:
          color: '#0000ff'
  )

  drawControlEditOnly = new L.Control.Draw(
    edit: featureGroup: editDrawnItems
    draw: false
  )

  editMap.addControl(drawControlEditOnly)

  editMap.on "draw:created", (e) =>
    layer = e.layer;
    layer.addTo(editDrawnItems);
    editMap.removeControl(drawControlFull)
    editMap.addControl(drawControlEditOnly)
    $('#edit_geo_zone_geom').val(JSON.stringify(layer.toGeoJSON()))

  editMap.on "draw:edited", (e) =>
    $('#edit_geo_zone_geom').val(JSON.stringify(e.layer.toGeoJSON()))
    console.log check
    for ob in object.keys(editDrawnItems._layers)
      console.log editDrawnItems._layers[ob].toGeoJSON()

  editMap.on "draw:deleted", (e) =>
    check = Object.keys(editDrawnItems._layers).length
    if (check == 0)
      editMap.removeControl(drawControlEditOnly)
      editMap.addControl(drawControlFull)
      $('#edit_geo_zone_geom').removeAttr('value')

initModals = ->
  $('.modal.map').modal(
    ready: (modal, trigger) =>
      newMap.invalidateSize()
      editMap.invalidateSize()
  )

bindEditEvent = ->
  $(document).on 'click', '.edit_event_btn', (e) ->
    e.preventDefault()

    event = window.events.filter((event) =>
      event.id == $(this).parents("tr").data("id"))[0]

    $("#edit_event_name").val(event.name)
    $("#edit_event_name").parent().addClass('is-dirty')
    $("#edit_event_syrus").val(event.syrus)
    $("#edit_event_syrus").parent().addClass('is-dirty')
    $("#edit_event_tk103").val(event.tk103)
    $("#edit_event_tk103").parent().addClass('is-dirty')
    $("#edit_event_form").attr("action","/events/"+event.id)
    Materialize.updateTextFields();

bindEditDevice = ->
  $(document).on 'click', '.edit_device_btn', (e)->
    console.log 'asdf'

    e.preventDefault()

    device = window.devices.filter((device) =>
      console.log device.id
      device.id == $(this).parents("tr").data("id"))[0]

    $("#edit_device_name").val(device.name)
    $("#edit_device_name").parent().addClass('is-dirty')
    $("#edit_device_imei").val(device.imei)
    $("#edit_device_imei").parent().addClass('is-dirty')
    $("#edit_device_phone").val(device.phone)
    $("#edit_device_phone").parent().addClass('is-dirty')
    #$('#edit_device_company_id')[0].selectize.setValue(device.company_id) if $('#edit_device_company_id')[0]
    #$('#edit_device_driver_id')[0].selectize.setValue(device.driver_id) if $('#edit_device_driver_id')[0]
    #$('#edit_device_icon')[0].selectize.setValue(device.icon) if $('#edit_device_icon')[0]
    $("#edit_device_form").attr("action","/devices/" + device.id)
    Materialize.updateTextFields();

bindEditCompany = ->
  $(document).on 'click', '.edit_company_btn', (e)->
    e.preventDefault()

    company = window.companies.filter((company) =>
      company.id == $(this).parents("tr").data("id"))[0]

    $("#edit_company_name").val(company.name)
    $("#edit_company_name").click()
    $("#edit_company_form").attr("action","/companies/"+company.id)
    Materialize.updateTextFields();

bindEditDriver = ->
  $(document).on 'click', '.edit_driver_btn', (e)->
    e.preventDefault()

    driver = window.drivers.filter((driver) =>
      driver.id == $(this).parents("tr").data("id"))[0]

    $("#edit_driver_name").val(driver.name)
    $("#edit_driver_name").parent().addClass('is-dirty')
    $("#edit_driver_rut").val(driver.rut)
    $("#edit_driver_rut").parent().addClass('is-dirty')
    #$('#edit_driver_company_id')[0].selectize.setValue(driver.company_id) if $('#edit_driver_company_id')[0]
    $("#edit_driver_form").attr("action","/drivers/"+driver.id)
    Materialize.updateTextFields()

bindEditGroup = ->
  $(document).on 'click', '.edit_group_btn', (e)->
    e.preventDefault()

    group = window.groups.filter((group) =>
      group.id == $(this).parents("tr").data("id"))[0]

    $("#edit_group_name").val(group.name)
    $("#edit_group_name").parent().addClass('is-dirty')
    #$('#edit_group_company_id')[0].selectize.setValue(group.company_id) if $('#edit_group_company_id')[0]
    $("#edit_group_form").attr("action","/groups/"+group.id)
    Materialize.updateTextFields();



bindEditCouples_type = ->
  $(document).on 'click', '.edit_couples_type_btn', (e)->
    e.preventDefault()

    couples_type = window.couples_types.filter((couples_type) =>
      couples_type.id == $(this).parents("tr").data("id"))[0]

    $("#edit_couples_type_couple_name").val(couples_type.couple_name)
    $("#edit_couples_type_high").val(couples_type.high)
    $("#edit_couples_type_width").val(couples_type.width)
    $("#edit_couples_type_long").val(couples_type.long)
    $("#edit_couples_type_weight").val(couples_type.weight)
    $("#edit_couples_type_name").parent().addClass('is-dirty')

    $("#edit_couples_type_form").attr("action","/couples_types/"+couples_type.id)
    Materialize.updateTextFields();

bindEditUser = ->
  $(document).on 'click', '.edit_user_btn', (e)->
    e.preventDefault()

    user = window.users.filter((user) =>
      user.id == $(this).parents("tr").data("id"))[0]

    $("#edit_user_email").val(user.email)
    $("#edit_user_email").parent().addClass('is-dirty')
    #$('#edit_user_role')[0].selectize.setValue(user.role) if $('#edit_user_role')[0]
    #$('#edit_user_company_id')[0].selectize.setValue(user.company_id) if $('#edit_user_company_id')[0]
    $("#edit_user_form").attr("action","/users/"+user.id)
    Materialize.updateTextFields();

bindEditDeviceEvent = ->
  $(document).on 'click', '.edit_device_event_btn', (e)->
    e.preventDefault()

    device_event = window.device_events.filter((device_event) =>
      device_event.id == $(this).parents("tr").data("id"))[0]

    #$('#edit_device_event_event_id')[0].selectize.setValue(device_event.event_id) if $('#edit_device_event_event_id')[0]
    #$('#edit_device_event_device_id')[0].selectize.setValue(device_event.device_id) if $('#edit_device_event_device_id')[0]
    alert = $("#edit_device_event_is_alert")
    if device_event.is_alert then alert.attr('checked','checked') else alert.removeAttr('checked')
    $("#edit_device_event_form").attr("action","/device_events/"+device_event.id)
    Materialize.updateTextFields();

bindEditGeoZone = ->
  $(document).on 'click', '.edit_geo_zone_btn', (e)->
    e.preventDefault()

    geo_zone = window.geo_zones.filter((geo_zone) =>
      geo_zone.id == $(this).parents("tr").data("id"))[0]

    editDrawnItems.clearLayers()

    wicket = new Wkt.Wkt()
    wicket.read(geo_zone.geom)
    feature = wicket.toObject()
    feature.addTo(editDrawnItems)

    editMap.fitBounds(feature.getBounds())

    $("#edit_geo_zone_geom").val(geo_zone.geom)
    $("#edit_geo_zone_name").val(geo_zone.name)
    enter_alert = $("#edit_geo_zone_enter_alert")
    if geo_zone.enter_alert then enter_alert.attr('checked','checked') else enter_alert.removeAttr('checked')
    exit_alert = $("#edit_geo_zone_exit_alert")
    if geo_zone.exit_alert then exit_alert.attr('checked','checked') else exit_alert.removeAttr('checked')
    send_report = $("#edit_geo_zone_send_report")
    if geo_zone.send_report then send_report.attr('checked','checked') else send_report.removeAttr('checked')
    panic = $("#edit_geo_zone_panic")
    if geo_zone.panic then panic.attr('checked','checked') else panic.removeAttr('checked')
    low_battery = $("#edit_geo_zone_low_battery")
    if geo_zone.low_battery then low_battery.attr('checked','checked') else low_battery.removeAttr('checked')
    shutdown = $("#edit_geo_zone_shutdown")
    if geo_zone.shutdown then shutdown.attr('checked','checked') else shutdown.removeAttr('checked')
    restart_on = $("#edit_geo_zone_restart_on")
    if geo_zone.restart_on then restart_on.attr('checked','checked') else restart_on.removeAttr('checked')
    ignicion = $("#edit_geo_zone_ignicion")
    if geo_zone.ignicion then ignicion.attr('checked','checked') else ignicion.removeAttr('checked')
    c_open = $("#edit_geo_zone_c_open")
    if geo_zone.c_open then c_open.attr('checked','checked') else c_open.removeAttr('checked')
    c_close = $("#edit_geo_zone_c_close")
    if geo_zone.c_close then c_close.attr('checked','checked') else c_close.removeAttr('checked')
    desenganche = $("#edit_geo_zone_desenganche")
    if geo_zone.desenganche then desenganche.attr('checked','checked') else desenganche.removeAttr('checked')
    cg_open = $("#edit_geo_zone_cg_open")
    if geo_zone.cg_open then cg_open.attr('checked','checked') else cg_open.removeAttr('checked')
    cg_closed = $("#edit_geo_zone_cg_closed")
    if geo_zone.cg_closed then cg_closed.attr('checked','checked') else cg_closed.removeAttr('checked')
    stop_report = $("#edit_geo_zone_stop_report")
    if geo_zone.stop_report then stop_report.attr('checked','checked') else stop_report.removeAttr('checked')
    excess_limit = $("#edit_geo_zone_excess_limit")
    if geo_zone.excess_limit then excess_limit.attr('checked','checked') else excess_limit.removeAttr('checked')
    end_excess_limit = $("#edit_geo_zone_end_excess_limit")
    if geo_zone.end_excess_limit then end_excess_limit.attr('checked','checked') else end_excess_limit.removeAttr('checked')

    $("#edit_geo_zone_form").attr("action","/geo_zones/"+geo_zone.id)

    Materialize.updateTextFields();

bindEditTravelSheet = ->
  $(document).on 'click', '.edit_travelsheet_btn', (e)->
    e.preventDefault()

    travel_sheet = window.travel_sheets.filter((travel_sheet) =>
      travel_sheet.id == $(this).parents("tr").data("id"))[0]

    console.log travel_sheet

    $("#edit_travel_sheets_name").val(travel_sheet.travel_name)
    $("#edit_travel_sheets_name").parent().addClass('is-dirty')
    $("#edit_travel_sheets_form").attr("action","/travel_sheets/"+travel_sheet.id)
    Materialize.updateTextFields();




### Menu config ###
bindMenuConfig = ->
  $(".config-menu").on 'click' , () ->
    $(".current-menu-config").hide()
    $(".collection-item").removeClass 'active'
    $(this).addClass 'active'
    $("#config-menu-"+$(this).data('menu')).show()


$(document).on 'ready', ->
  ### init config menu ###



  bindEditDevice()
  bindEditEvent()
  bindEditCompany()
  bindEditDriver()
  bindEditUser()
  bindEditDeviceEvent()
  bindEditGeoZone()
  bindEditGroup()
  initNewGeoZoneMap()
  initEditGeoZoneMap()

  ### Menu config ###
  bindMenuConfig()
  bindEditCouples_type()


  initModals()
  bindEditTravelSheet()
