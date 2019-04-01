report_f_date = report_i_date = null
playback_reports_table = null
c_date_i = c_date_f = c_time_i = c_time_f =null
window.points = null
currentTimestamp = 0
imei_global_param = null

queryString = () ->
  query_string = {}
  query = window.location.search.substring(1)
  vars = query.split("=")
  console.log vars[1]
  imei_global_param = vars[1]
  if imei_global_param
    do_playback_report()



mapPathConfig =
  domId: 'playback_map'
  initialPosition: [-33.449559, -70.671239]
  initialZoom: 11
  minZoom: 3

iconSYRUS = L.icon({
  iconUrl: '/icons/market_place_2.png',
  iconSize: [30, 30],
  iconAnchor: [5, 0]
})
iconTK103 = L.icon({
  iconUrl: '/icons/market_place_2.png',
  iconSize: [30, 30],
  iconAnchor: [0, 0]
})
iconAMOS3005 = L.icon({
  iconUrl: '/icons/market_place_2.png',
  iconSize: [30, 30],
  iconAnchor: [0, 0]
})
playback = null

assetLayerGroup = new L.LayerGroup()
playback_is_play = false


slider_playback = null

$(document).on 'ready', ->
  create_playback_map()
  queryString()


  Materialize.updateTextFields()
  $('#search_playback_report').on 'click', ->
    do_playback_report()
  $("#report_tab_playback").show()
  $("#report_tab_speed").hide()
  $("#report_tab_stop").hide()
  $("#report_tab_dialyActivities").hide()
  $("#report_tab_alerts").hide()
  $("#report_tab_geozone").hide()
  $('#modal_map_information').modal(
    dismissible: false,
  )

playbackOptions =
  playControl: false
  dateControl: false
  sliderControl: false
  maxInterpolationTime: 5 * 60 * 1000
  orientIcons: false
  layer:
    pointToLayer: (featureData, latlng) ->
      result = {}
      if featureData and featureData.properties and featureData.properties.path_options
        result = featureData.properties.path_options
      if !result.radius
        result.radius = 5
      new (L.CircleMarker)(latlng, result)
  marker: (featureData) ->
    {icon: eval("icon#{featureData.properties.icon}"), name: 'marker'}

mapPath = mapSpeeds = mapStops = null

onPlaybackTimeChange = (timestamp) ->
  indexOfTimestamp = window.points.properties.time.indexOf(timestamp)
  return if indexOfTimestamp < 0
  position = window.points.geometry.coordinates[indexOfTimestamp].slice().reverse()
  mapPath.panTo(position) if indexOfTimestamp > 0
  speed = window.points.properties.speed[indexOfTimestamp]

  $("#velocity").html(Math.round(speed) + " Km/h")
  $("#date").html(moment(timestamp).format('DD/MM/YYYY'))
  $("#time").html(moment(timestamp).format('HH:mm:ss'))

  setTimeout ( -> slider_playback.noUiSlider.set(timestamp)), 2


show_playback = ->
  playback = new L.Playback(mapPath, window.points, onPlaybackTimeChange, playbackOptions)
  playback.setSpeed(9)
  playback.stop()
  points = window.points.geometry.coordinates.map (coords) ->
    coords.slice().reverse()

  trace = new L.polyline(points, {
    color: 'red',
    weight: 3,
    opacity: 0.6
    smoothFactor: 6
  })

  if slider_playback
    slider_playback.noUiSlider.updateOptions({
      start: [playback.getStartTime()],
      connect: [true, false]
      range: {
        'min': playback.getStartTime(),
        'max': playback.getEndTime()
      }
    })
  else
    slider_playback = document.getElementById('time-slider')
    noUiSlider.create(slider_playback, {
      start: [playback.getStartTime()],
      connect: [true, false]
      range: {
        'min': playback.getStartTime(),
        'max': playback.getEndTime()
      }
    })

  slider_playback.noUiSlider.on('end', () ->
    if playback_is_play
      playback.start()
  )
  slider_playback.noUiSlider.on('slide', () ->
    if playback.isPlaying() == true
      playback.stop()
      playback_is_play = true

    playback.setCursor slider_playback.noUiSlider.get()
    mapPath.eachLayer((layer) ->
      if layer.options.name == 'marker'
        mapPath.panTo([layer._latlng.lat, layer._latlng.lng])
    )
  )


  $('.play-pause').click ->
    $('.play-pause').hide()
    if playback.isPlaying() == false
      playback.start()
      $(".pause").show()
      if currentTimestamp != 0
        playback.setCursor(currentTimestamp)
    else
      $(".play").show()
      playback.stop()
      playback_is_play = false


  trace.addTo(mapPath)
  mapPath.fitBounds(trace.getBounds())
  assetLayerGroup.addLayer(trace)
  $('input[type="checkbox"].leaflet-control-layers-selector').attr('id', 'gps_tracks')
  $('#gps_tracks').next().replaceWith("<label for='gps_tracks'>GPS Tracks</label>")


create_playback_map = () ->
  if $("#" + mapPathConfig.domId).length == 1
    if mapPath
      mapPath.remove()

    mapPath = L.map(mapPathConfig.domId, {
      minZoom: mapPathConfig.minZoom,
      worldCopyJump: true
    }).setView(mapPathConfig.initialPosition, mapPathConfig.initialZoom)
    osmUrl = 'http://{s}.tile.openstreetmap.se/hydda/full/{z}/{x}/{y}.png'
    osmAttrib = ''
    osm = new L.TileLayer(osmUrl, {attributionControl: false})
    mapPath.addLayer(osm)


do_playback_report = ->
  c_date_i = $('#report_i_date_playback').val()
  c_date_f = $('#report_f_date_playback').val()
  c_time_i = $('#report_i_time_playback').val()
  c_time_f = $('#report_f_time_playback').val()
  if(!imei_global_param)

    imei_global_param = $("#playbacks_devices").val()
    console.log imei_global_param

  Materialize.toast('Consultando Base de Datos', (1000) * 60 * 5)
  $.ajax '/information/report_playback',
    type: 'GET'
    data: {
      from_date: c_date_i
      from_time: c_time_i
      to_date: c_date_f
      to_time: c_time_f
      velocity_limit: $('#report_f_playback').val()
      imei: imei_global_param
    }
    error: (jqXHR, textStatus, errorThrown) ->
      Materialize.toast('Error al listar los datos...', 4000)
      console.log textStatus
      $('.toast').remove()
      imei_global_param = null
    success: (data, textStatus, jqXHR) ->
      imei_global_param = null
      $('.toast').remove()
      Materialize.toast('Consulta Realizada', (1000) * 2)
      if data.error
        Materialize.toast(data.error, 5000)
        return
      window.points = data
      create_playback_map()
      playback_is_play = false
      if playback != null
        playback.stop()
      show_playback()
      console.log data




