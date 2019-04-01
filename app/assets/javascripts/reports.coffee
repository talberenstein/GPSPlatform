mapPathConfig =
  domId: 'map_path_report'
  initialPosition: [-33.449559, -70.671239] # Santiago de Chile
  initialZoom: 13
  minZoom: 7

mapSpeedsConfig =
  domId: 'map_speeds_graph'
  initialPosition: [-33.449559, -70.671239] # Santiago de Chile
  initialZoom: 13
  minZoom: 7

mapStopsConfig =
  domId: 'map_stops_graph'
  initialPosition: [-33.449559, -70.671239] # Santiago de Chile
  initialZoom: 13
  minZoom: 7

iconSYRUS = L.icon({
    iconUrl: image_path('car-SYRUS.svg'),
    iconSize: [40, 40],
    iconAnchor: [52, 52]
})
iconTK103 = L.icon({
    iconUrl: image_path('car-TK103.svg'),
    iconSize: [30, 30],
    iconAnchor: [15, 15]
})

playbackOptions =
  playControl: true
  dateControl: false
  sliderControl: true
  maxInterpolationTime: 15 * 60 * 1000
  orientIcons: true
  layer: pointToLayer: (featureData, latlng) ->
    result = {}
    if featureData and featureData.properties and featureData.properties.path_options
      result = featureData.properties.path_options
    if !result.radius
      result.radius = 5
    new (L.CircleMarker)(latlng, result)
  marker: (featureData) ->
    {icon: eval("icon#{featureData.properties.icon}")}

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

$(document).on 'ready', ->
  if $("#"+mapPathConfig.domId).length == 1
    ######## Inicializar el mapa con las capas de Open Street Maps ############
    mapPath = L.map(mapPathConfig.domId, {minZoom: mapPathConfig.minZoom, worldCopyJump: true}).setView(mapPathConfig.initialPosition, mapPathConfig.initialZoom)
    #osmUrl='http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.svg'
    osmUrl='http://{s}.tile.openstreetmap.se/hydda/full/{z}/{x}/{y}.png'
    osmAttrib=''
    osm = new L.TileLayer(osmUrl, {attributionControl: false})
    mapPath.addLayer(osm)

    playback = new L.Playback(mapPath, window.points, onPlaybackTimeChange, playbackOptions)

    points = window.points.geometry.coordinates.map (coords) ->
        coords.slice().reverse()

    trace = new L.polyline(points, {
        color: 'red',
        weight: 3,
        opacity: 0.6
        smoothFactor: 1
    })

    trace.addTo(mapPath)

    mapPath.fitBounds(trace.getBounds())

  if $("#"+mapSpeedsConfig.domId).length == 1
    ######## Inicializar el mapa con las capas de Open Street Maps ############
    mapSpeeds = L.map(mapSpeedsConfig.domId, {minZoom: mapSpeedsConfig.minZoom, worldCopyJump: true}).setView(mapSpeedsConfig.initialPosition, mapSpeedsConfig.initialZoom)
    #osmUrl='http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.svg'
    osmUrl='http://{s}.tile.openstreetmap.se/hydda/full/{z}/{x}/{y}.png'
    osmAttrib=''
    osm = new L.TileLayer(osmUrl, {attributionControl: false})
    mapSpeeds.addLayer(osm)

    points = window.speeds_graph_points.geometry.coordinates.map (coords) ->
        coords.slice().reverse()

    trace = new L.polyline(points, {
        color: 'red',
        weight: 3,
        opacity: 0.6
        smoothFactor: 1
    })

    trace.addTo(mapSpeeds)

    mapSpeeds.fitBounds(trace.getBounds())

    new L.CircleMarker(points[0], {radius: 5, color: 'blue'}).bindTooltip('Comienzo Exceso de Velocidad', {permanent: true}).addTo(mapSpeeds)
    new L.CircleMarker(points[points.length - 1], {radius: 5, color: 'blue'}).bindTooltip('Fin Exceso de Velocidad', {permanent: true}).addTo(mapSpeeds)

  if $("#"+mapStopsConfig.domId).length == 1
    ######## Inicializar el mapa con las capas de Open Street Maps ############
    mapStops = L.map(mapStopsConfig.domId, {minZoom: mapStopsConfig.minZoom, worldCopyJump: true}).setView(mapStopsConfig.initialPosition, mapStopsConfig.initialZoom)
    #osmUrl='http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.svg'
    osmUrl='http://{s}.tile.openstreetmap.se/hydda/full/{z}/{x}/{y}.png'
    osmAttrib=''
    osm = new L.TileLayer(osmUrl, {attributionControl: false})
    mapStops.addLayer(osm)

    L.marker(window.stops_graph, {icon: iconTK103}).addTo(mapStops)

    mapStops.setView(window.stops_graph,18)

  $('a[href="#reports"]').on 'click', ->
    setTimeout(->
      mapPath.invalidateSize() if mapPath
      mapSpeeds.invalidateSize() if mapSpeeds
      mapStops.invalidateSize() if mapStops
    ,100)

  $('input[type="checkbox"].leaflet-control-layers-selector').attr('id','gps_tracks')
  $('#gps_tracks').next().replaceWith("<label for='gps_tracks'>GPS Tracks</label>")