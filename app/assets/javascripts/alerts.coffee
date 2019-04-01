mapConfig =
  domId: 'map_alerts'
  initialPosition: [-33.449559, -70.671239] # Santiago de Chile
  initialZoom: 13
  minZoom: 7

icon = L.icon({
  iconUrl: image_path('alert.svg'),
  iconSize: [15, 15]
  iconAnchor: [7.5, 7.5]
})

map = null
map_alerts = []

moveToTab = (id) ->
  $('a[href="' + id + '"]').click()



cleanAlertInfo = ->
  $("#device_info_alerts #date").html("")
  $("#device_info_alerts #time").html("")
  $("#device_info_alerts #event").html("")
  $("#device_info_alerts #address").html("")

updateAlertInfo = (alert) ->
  event = (window.events.filter (e) ->
    e.id == alert.event_id
  )[0]

  device = (window.devices.filter (d) ->
    d.id == alert.device_id
  )[0]
  $("#device_info_alerts #date").html(moment(alert.date).format('DD/MM/YYYY'))
  $("#device_info_alerts #time").html(moment(alert.date).format('HH:mm:ss'))
  $("#device_info_alerts .name").html(device.name)
  $("#device_info_alerts #event").html(event.name)
  geocodeService = L.esri.Geocoding.geocodeService()
  geocodeService.reverse().latlng(alert.coords).run (error, result) ->
    $("#device_info_alerts #address").html(result.address.Match_addr) if result and result.address




bindViewAlert = ->
  $(document).on 'click', 'a.view_alert', (e) ->
    e.preventDefault()

    $('a.view_alert').parents("tr").css('background-color', 'white')
    $(this).parents("tr").css('background-color', 'lightblue')
    map.setZoom(18)

    alert = (map_alerts.filter (map_alert) =>
      map_alert.id == $(this).data('alert-id')
    )[0]
    position = alert.coords
    map.panTo(position)
    updateAlertInfo(alert)

bindTrackAlert = ->
  $(document).on 'click', 'a.track_alert', (e) ->
    e.preventDefault()
    $('a.track_alert').parents("tr").css('background-color', 'white')
    $(this).parents("tr").css('background-color', 'lightblue')
    alert = (map_alerts.filter (map_alert) =>
      map_alert.id == $(this).data('alert-id')
    )[0]
    moveToTab("#tracking")
    $('#track_checkbox_'+alert.device_id).click() unless $('#track_checkbox_' + alert.device_id + ":checked").length == 1
    position = alert.coords
    map.panTo(position)
    updateAlertInfo(alert)

bindDoneAlert = ->
  $(document).on 'click', '.done_alert', (e) ->
    e.preventDefault()
    alert = (map_alerts.filter (map_alert) ->
      map_alert.id == $(e.target).parent().data('alert-id')
    )[0]
    console.log "alert: ": +alert
    console.log "alert.id: "+$(e.target).parent().data('alert-id')
    $.ajax(
      url: '/alerts/' + alert.id + '/seen'
      type: 'PUT'
      success: =>
        alert.marker.removeFrom(map)
        $(this).parents("div.collapsible-body").remove()
        device = (window.devices.filter (d) ->
          d.id == alert.device_id
        )[0]
        group = (window.groups.filter (g) ->
          g.id == device.group_id
        )[0]
        aux = $("#group_"+group.id).children().length-2
        console.log aux
        $('#group_'+group.id+' #count_alerts').html(aux)
        $('#group_'+group.id+' #count_alerts2').html(" ("+aux+")")
        cleanAlertInfo()
    )

resizeMap = ->
  actualHeight = $(window).height() - 50
  maxHeight = $(window).height() * $(window).width() / 1000
  maxHeight = if maxHeight < actualHeight then maxHeight else actualHeight
  $(".mapGeneric_alert").height maxHeight
  map.invalidateSize

addAlert = (alert) ->
  event = (window.events.filter (e) ->
    e.id == alert.event_id
  )[0]

  device = (window.devices.filter (d) ->
    d.id == alert.device_id
  )[0]

  group = (window.groups.filter (g) ->
    g.id == device.group_id
  )[0]

  if alert.description
    geo_zone = (window.geo_zones.filter (g) ->
      g.name == alert.description
    )[0]

  map_alerts.push alert


  newAlert = "<div class='collapsible-body col s12'>"
  newAlert += "<a href='#' class='view_alert col s3' data-alert-id='" + alert.id + "'>" + device.name + "</a>" +
      "<a class='col s3' data-alert-id='" + alert.id + "'>" + event.name + "</a>" +
      "<a class='col s3' data-alert-id='" + alert.id + "'>" + moment(alert.date).format('DD/MM/YY HH:mm:ss') + "</a>" +
      "<a href='#' class='col s3 done_alert' data-alert-id='" + alert.id + "'><img style='width: 30%; height: 30%; margin-top: 1%;' src='" + image_path('alerta-verificacion-ok.svg') + "'/></a>"
  newAlert += "</div>"

  console.log "newAlert: "+newAlert

  aux = $("#group_"+group.id).children().length-1
  $('#group_'+group.id+' #count_alerts').html(aux)
  $('#group_'+group.id+' #count_alerts2').html(" ("+aux+")")
  $("#group_"+group.id).append(newAlert)



 ##alert.marker = L.marker(alert.coords,{icon: icon}).bindTooltip(device.name, {permanent: true}).addTo(map)
 #alert.marker.on 'click', ->
 #  updateAlertInfo(alert)



 #html = "<tr>"
 #html += "<td class='mdl-data-table__cell--non-numeric'><a href='#' class='view_alert' data-alert-id='" + alert.id + "'>" + device.name + "</a></td>"
 #html += "<td class='mdl-data-table__cell--non-numeric'>" + event.name + (if alert.description then " (#{alert.description}) " else "") + "</td>"
 #html += "<td class='mdl-data-table__cell--non-numeric'>" + moment(alert.date).format('DD/MM/YY HH:mm:ss') + "</td>"
 #html += "<td class='mdl-data-table__cell--non-numeric'><a href='#' class='done_alert' data-alert-id='" + alert.id + "'><img src='" + image_path('alerta-verificacion-ok.svg') + "'/></a></td>"
 #html += "<td class='mdl-data-table__cell--non-numeric'><a href='#' class='track_alert' data-alert-id='" + alert.id + "'><img src='" + image_path('track-alerta.svg') + "'/></a></td>"
 #html += "</tr>"
 #$("#alerts_table tbody").append(html);

$(document).on 'ready', ->
  return if $("#"+mapConfig.domId).length == 0
  ######## Inicializar el mapa con las capas de Open Street Maps ############
  map = L.map(mapConfig.domId, {minZoom: mapConfig.minZoom, worldCopyJump: true}).setView(mapConfig.initialPosition, mapConfig.initialZoom)
  #osmUrl='https://api.tiles.mapbox.com/v4/mapbox.mapbox-streets-v7/{z}/{x}/{y}.svg?access_token=pk.eyJ1IjoidGluY2hvZ29uMzQiLCJhIjoiY2lyNnVjMWhlMDBvM2c3bTMwdjNkbGFrZSJ9.E7Yi-0AKUaxd26to_RAD3g'
  #osmUrl='http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.svg'
  osmUrl='http://{s}.tile.openstreetmap.se/hydda/full/{z}/{x}/{y}.png'
  osmAttrib=''
  osm = new L.TileLayer(osmUrl, {attributionControl: false})
  map.addLayer(osm)
  $('.collapsible').collapsible()

  _.each window.unseen_alerts, (alert) ->
    addAlert(alert)

  bindViewAlert()
  bindDoneAlert()
  bindTrackAlert()
  resizeMap()

  $('a[href="#alerts"]').on 'click', ->
    setTimeout(->
      map.invalidateSize()
    ,100)

  # Escuchar mensajes de alertas
  console.log "asdf"
  window.channel.on "new_alert", (msg) ->
    console.log msg
    #return unless msg.gps_valid
    alert = {}
    alert.id = msg.id
    alert.device_id = msg.device_id
    alert.event_id = msg.event_id
    alert.coords = msg.geom.coordinates.slice().reverse()
    alert.seen = msg.seen
    alert.date = new Date(msg.gps_date)
    alert.description = msg.description

    console.log alert
    console.log "asddfdsfdfadsf"
    addAlert(alert)
    console.log "updateAlertInfo"
    updateAlertInfo(alert)
