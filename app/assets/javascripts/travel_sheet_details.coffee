mapConf =
    initialPosition: [-33.449559, -70.671239] # Santiago de Chile
    initialZoom: 14
    minZoom: 6
    id: 'preview_map'
map = null


$(document).on 'ready', ->
    if !window.ts
        return

    map = L.map(mapConf.id, {
        minZoom: mapConf.minZoom,
        worldCopyJump: true
    }).setView(mapConf.initialPosition, mapConf.initialZoom)
    osmUrl = 'http://{s}.tile.openstreetmap.se/hydda/full/{z}/{x}/{y}.png'
    osm = new L.TileLayer(osmUrl, {attributionControl: false})
    map.addLayer(osm)
    map.invalidateSize()

    markersSz = []
    markersSzLayer = new L.LayerGroup()


    for pr in window.ts.travel_locations

        x = pr
        x = x.location.coordinate.replace('POINT (', '').replace(')', '')
        x = x.split(' ')


        icon = L.icon(
            iconUrl: '/icons/marker_' + pr.step + '.svg'
            iconSize: [44, 52]
        )
        content = pr.location.location_name + '<br>' + pr.location.location_address
        markerSingle = L.marker([x[0], x[1]], {icon: icon}).bindPopup(content)
        markersSz.push(markerSingle)
        markersSzLayer.addLayer(markerSingle)
        markerSingle.on 'mouseover', ->
            this.openPopup()

          markerSingle.on 'mouseout', ->
              this.closePopup()

    route = []
    colors = ['green', 'blue', 'red', 'yellow', 'purple', 'orange']

    iteration = 0
    for r in window.ts.routes
        geoms = r.route_geo.replace('LINESTRING (', '').replace(')', '').split(', ')
        route = []
        for x in geoms
            x = x.split(' ')
            route.push([x[1], x[0]])
        color = colors[iteration]

        iteration += 1
        if iteration > colors.length
            iteration = 0
        content = 'Hacia: ' + r.route_name

        markerSingle = L.polyline(route, {color: color, weight: 4}).bindPopup(content)
        markerSingle.on 'mouseover', ->
            this.openPopup()

        markerSingle.on 'mouseout', ->
            this.closePopup()

        markersSzLayer.addLayer(markerSingle)

    group = new L.featureGroup(markersSz)

    map.fitBounds(group.getBounds())
    markersSzLayer.addTo(map)

