# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
id_from_update = null
travel_sheet =
    travel_name: null
    state: 'ready_to_dispatch'
    is_template: false
    device_id: null
    couples_type_id: null
    driver_id: null
    owner_id: null
    travel_locations_attributes: []
    route_id: null
    date_travel: null

stoppedZonesMap =
    initialPosition: [-33.449559, -70.671239] # Santiago de Chile
    initialZoom: 13
    minZoom: 7

marker_origin = null
position_origin = null
position_routes = []
current_custom_search = null
mapConf =
    initialPosition: [-33.449559, -70.671239] # Santiago de Chile
    initialZoom: 14
    minZoom: 6
map = null
routes_lines = null
markers = []

travel_sheet_search_from_date = travel_sheet_search_to_date = picker = null
stoppedZones_Map = null

allowed_stopped_zones = []

maneuver = []


marker_ts = null
markers_ts_layout = null
markers_ts_layout = new L.LayerGroup()

$(document).on 'ready', ->
    setTimeout (->
          setTimeout ( ->
              $('.background').fadeOut 'slow', ->
                  $('.loading').fadeIn 'slow', ->
                      $("body").css('background', "#fff")
                      window.dispatchEvent(new Event('resize'))
          ), 500
          ###$('#tracking').hide()
          $('#travel_sheets').show()###
          ##$('#new_travel_sheets_modal').modal 'open'
          Materialize.updateTextFields()
      ),
      500


    $('.stepper').activateStepper()
    $('.step').on 'click', (event)->
        event.stopPropagation()


    load_travel_sheet_principal_table()
    $('#print_travel_sheet').on 'click', ->
        $("#to_print").printThis
            debug: false
            importCSS: true
            importStyle: true
            printContainer: true
            printDelay: 666
            header: null
            footer: null
            base: false
            formValues: true
            canvas: false


    $('#draw').on 'click', ->
        travel_sheet_resume()
    $('#search_travel_sheets').on 'click', ->
        search_travel_sheets()

    $('#pre_seleccted_zones').on 'change', ->
        editDrawnItems = L.geoJson(
          [],
            style: (feature) ->
                color: feature.geometry.properties.color
            onEachFeature: (feature, layer) ->
                layer.bindPopup(feature.properties.name);
        ).addTo(stoppedZones_Map)

        for l in window.geo_zones
            wicket = new Wkt.Wkt()
            wicket.read(l.geom)
            feature = wicket.toObject()
            feature.addTo(editDrawnItems)


    $(".modal-next").on 'click', ->
        aS = $('.stepper').getActiveStep()
        console.info aS
        if aS == 1
            if validate_fields_per_page('.validate_not_empty')
                $('.stepper').nextStep()
                setTimeout (->
                      initPreviewMap 'preview_map'
                      window.dispatchEvent(new Event('resize'))
                      setTimeout ( ->
                          set_marker(false, map, markers_ts_layout)
                      ), 500
                  ),
                  500
            return
        if aS == 2

            if position_origin != null and position_routes.length > 0
                $('.stepper').nextStep()

                setTimeout (->
                      initPermitStoppedZonesMap()
                      draw_layer_to_stopped_zones_map(stoppedZones_Map)
                      window.dispatchEvent(new Event('resize'))

                  ),
                  500
            else
                Materialize.toast('Debe agregar almenos una ruta', 4000)

            return false
        if aS == 3
            $('.stepper').nextStep()
            $('#next_travel_sheet').hide()
            $('#save_travel_sheet').show()
            travel_sheet_resume()


    $(".modal-prev").on 'click', ->
        console.log $('.stepper').getActiveStep()
        if $('.stepper').getActiveStep() != 1
            $('.stepper').prevStep()
            window.dispatchEvent(new Event('resize'))
            $('#save_travel_sheet').hide()
            $('#next_travel_sheet').show()
            setTimeout ( ->
                set_marker(false, map, markers_ts_layout)
            ), 250


    $(window).keydown (e) ->
        if e.keyCode == 13
            e.preventDefault()
            return false

    $('#timepicker_travel_sheets_start').on 'change', ->
        if position_origin != null
            position_origin.start_time = $(this).val()
            position_origin.end_time = $(this).val()

    $('.datepicker_travel').pickadate(
        closeOnSelect: true
        closeOnClear: true
        selectMonths: true
        selectYears: 15
        container: 'body'
        labelMonthNext: 'Mes Anterior'
        labelMonthPrev: 'Mes Siguiente'
        labelMonthSelect: 'Selecciona un mes'
        labelYearSelect: 'Selecciona un año'
        monthsFull: ['Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', 'Julio', 'Agosto', 'Septiembre', 'Octubre',
            'Noviembre', 'Diciembre']
        monthsShort: ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dec']
        weekdaysFull: ['Domingo', 'Lunes', 'Martes', 'Miercoles', 'Jueves', 'Viernes', 'Sábado']
        weekdaysShort: ['Dom', 'Lun', 'Mar', 'Mie', 'Jue', 'Vie', 'Sab']
        weekdaysLetter: ['D', 'L', 'M', 'M', 'J', 'V', 'S']
        today: 'Hoy',
        clear: 'Limpiar'
        close: 'Cerrar'
        firstDay: 1
        format: 'dd/mm/yyyy'
    )

    picker = $('.datepicker_travel').pickadate('picker')
    travel_sheet_search_from_date = $('#travel_sheet_search_from_date').pickadate('picker')
    travel_sheet_search_to_date = $('#travel_sheet_search_to_date').pickadate('picker')
    travel_sheet_search_from_date.set('select', moment().subtract(1, 'days').format('YYYY-MM-DD'), {format: 'yyyy-mm-dd'})
    travel_sheet_search_to_date.set('select', moment().format('YYYY-MM-DD'), {format: 'yyyy-mm-dd'})


    bindSearchBox_travel_sheets 'search_final_travel_sheet'
    bind_time_pickers_and_delete()
    setTimeout ( -> create_timeline()),2000

    $('#save_travel_sheet').on 'click', ->
        save_travel_sheet()

    $('#origin_travel_select').on 'change', -> ## add new origin route
        add_initial_route(parseInt($(this).val()))

    $('#final_travel_select').on 'change', -> ## add new preload route
        add_preload_route($(this))


    ## others events
    $('#new_travel_sheets_modal').modal(## on open load map
        ready: (modal, trigger) ->
            ###initPreviewMap 'preview_map'###
            $('.stepper').openStep(1)
            $('#next_travel_sheet').show()
            $('#save_travel_sheet').hide()
            reset()
        ,
        complete: () ->
            reset()
            $('.stepper').resetStepper(4)
            $('.stepper').resetStepper(3)
            $('.stepper').resetStepper(2)
            $('.stepper').resetStepper(1)

            if map != null
                map.remove()
                map = null
    )
    Materialize.updateTextFields()
    $('#generate_route').on 'click', ->
#generate_draw_new_route()
        waze_api()


#Inicia la nueva vista previa mapa
initPreviewMap = (divId) ->
    if map != null
        return
    map = L.map(divId, {
        minZoom: mapConf.minZoom,
        worldCopyJump: true
    }).setView(mapConf.initialPosition, mapConf.initialZoom)
    osmUrl = 'http://{s}.tile.openstreetmap.se/hydda/full/{z}/{x}/{y}.png'
    osm = new L.TileLayer(osmUrl, {attributionControl: false})
    map.addLayer(osm)
    map.invalidateSize()


#map.on('click', onMapClick)


### Google search box ###
bindSearchBox_travel_sheets = (inputId) ->
    input = document.getElementById inputId
    autocomplete = new google.maps.places.Autocomplete(input)
    autocomplete.addListener('place_changed', () ->
        place = autocomplete.getPlace()
        location_ob =
            location_address: place.formatted_address
            location_name: place.name

        current_custom_search =
            id: Math.floor(new Date().valueOf() * Math.random()),
            lat: place.geometry.location.lat(),
            lon: place.geometry.location.lng(),
            is_preload: false,
            location_name: location_ob.location_name,
            location_address: location_ob.location_address,
            coordinate: place.geometry.location.lat() + ' ' + place.geometry.location.lng(),
            step: 'place',
            state: 'ready_to_dispatch',
            start_time: moment().add(20, 'minutes').format('HH:mm'),
            end_time: moment().add(40, 'minutes').format('HH:mm')
            locations_attributes: [{
                location_name: location_ob.location_name,
                location_address: location_ob.location_address,
                coordinate: place.geometry.location.lat() + ' ' + place.geometry.location.lng(),
                is_display: false
            }]


        position_routes.push(current_custom_search)
        coors =
            x: current_custom_search.lat
            y: current_custom_search.lon

        create_row_final_travels(position_routes)

        set_marker(false, map, markers_ts_layout)
    )


bind_time_pickers_and_delete = ->
    $('.del_route').unbind 'click'

    $('.timepicker_travel_sheets').pickatime
        default: 'now',
        twelvehour: false,
        donetext: 'OK',
        autoclose: true

    $(".route_change_from").on 'change', ->
        id = $(this).attr('id').replace('i', '')
        for x in position_routes
            if x.id == parseInt(id)
                x.start_time = $(this).val()

    $(".route_change_to").on 'change', ->
        id = $(this).attr('id').replace('f', '')
        for x in position_routes
            if x.id == parseInt(id)
                x.end_time = $(this).val()

    $('.del_route').on 'click', -> ## remove route
        element = $(this).data 'del'
        $('#route-' + element).remove()
        for m in markers
            if m.id == element
                map.removeLayer(m)
                if routes_lines
                    map.removeLayer(routes_lines)

        i = 0
        while i < markers.length
            if markers[i].id == element
                markers.splice(i, 1)
            i++
        i = 0
        while i < position_routes.length
            if position_routes[i].id == element
                position_routes.splice(i, 1)
            i++
        generate_draw_new_route()
        set_marker(false, map, markers_ts_layout)
        create_row_final_travels(position_routes)


generate_draw_new_route = ->
    if position_origin == null || position_routes.length == 0
        return
    start = position_origin.lon + ',' + position_origin.lat
    steps = ''
    for r in position_routes
        steps += ';' + r.lon + ',' + r.lat

    url1 = 'https://router.project-osrm.org/route/v1/driving/' + start + steps + '?steps=true&alternatives=true'
    url2 = 'https://router.project-osrm.org/route/v1/driving/-70.61343569999997,-33.4173399;-70.61995256692171,-33.418976885360884?steps=true&alternatives=true'

    $.ajax url1,
        type: 'GET'
        dataType: 'json'
        error: (jqXHR, textStatus, errorThrown) ->
            console.textStatus
        success: (data, textStatus, jqXHR) ->
            maneuver = []
            console.info data
            if data.code == 'Ok'
                route = []
                iteration = 0
                for r in data.routes[0].legs
                    position_routes[iteration].route = []
                    position_routes[iteration].route_distance = data.routes[0].distance
                    position_routes[iteration].route_duration = data.routes[0].duration
                    for steps in r.steps
                        maneuver.push(steps)
                        for line in steps.intersections
                            route.push([line.location[1], line.location[0]])

                            position_routes[iteration].route.push(line.location =
                                lat: line.location[0], lon: line.location[1])
                    iteration++

                if routes_lines
                    map.removeLayer(routes_lines)
                routes_lines = L.polyline(route, {color: 'DodgerBlue', weight: 3}).addTo(map)
            else
                Materialize.toast('Error al generar la ruta...', 4000)


    return
    marker = new L.Marker(e.latlng, {draggable: true})
    map.addLayer marker
    markers[marker._leaflet_id] = marker

    $('#overlay > ul').append('Marker - <a href="#" class="remove" id="' + marker._leaflet_id + '">remove</a>')
    $('.remove').on "click", ->
        map.removeLayer(markers[$(this).attr('id')])
        $(this).parent('li').remove()
        delete markers[$(this).attr('id')]


add_initial_route = (id) -> ## select initial route from select
    location_ob = get_location id
    ## set route name
    route = location_ob.location_name + '<br>' + location_ob.location_address
    $('.start_route_address').html route
    coors = get_wkt(location_ob.coordinate)

    position_origin =
        state: 'ready_to_dispatch',
        step: 'start'
        start_time: moment().add(10, 'minutes').format('HH:mm'),
        end_time: moment().add(10, 'minutes').format('HH:mm')
        id: Math.floor(new Date().valueOf() * Math.random()),
        location_name: location_ob.location_name
        location_address: location_ob.location_address
        lat: coors.x,
        lon: coors.y,
        coordinate: coors.x + ' ' + coors.y,
        is_preload: true,
        locations_attributes: [{
            location_name: location_ob.location_name,
            location_address: location_ob.location_address,
            coordinate: coors.x + ' ' + coors.y,
            company_id: '1',
            is_display: false

        }]
    $("#timepicker_travel_sheets_start").val(position_origin.end_time).change()
    set_marker(false, map, markers_ts_layout)


add_preload_route = (el) -> ## select new route from select
    if !el.val()
        Materialize.toast('Debe seleccionar un destino primero...', 4000)
        return
    location_ob = get_location parseInt el.val()
    coors = get_wkt(location_ob.coordinate)

    current_custom_search =
        state: 'ready_to_dispatch',
        step: 'place'
        start_time: moment().add(20, 'minutes').format('HH:mm'),
        end_time: moment().add(40, 'minutes').format('HH:mm')
        id: Math.floor(new Date().valueOf() * Math.random()),
        location_name: location_ob.location_name
        location_address: location_ob.location_address
        lat: coors.x,
        lon: coors.y,
        coordinate: coors.x + ' ' + coors.y,
        is_preload: true,
        locations_attributes: [{
            location_name: location_ob.location_name,
            location_address: location_ob.location_address,
            coordinate: coors.x + ' ' + coors.y,
            is_display: false
        }]
    position_routes.push(current_custom_search)


    create_row_final_travels(position_routes)
    bind_time_pickers_and_delete()
    set_marker(false, map, markers_ts_layout)


get_location = (id) ->
    window.locations.filter((x) =>
        x.id == parseInt(id)
    )[0]

get_wkt = (o) ->
    wicket = new Wkt.Wkt()
    wicket.read(o)
    wicket.components[0] ## return x and y postition

set_marker = (no_route, obj_map, map_layer) -> #set marker map
    marker_ts = null
    markers_group = []

    if map_layer
        map_layer.clearLayers()

    icon = L.icon(
        iconUrl: 'icons/marker_start.svg'
        iconSize: [44, 52]
    )
    if position_origin != null

        content = position_origin.location_name + '<br>' + position_origin.location_address
        marker_ts = L.marker([position_origin.lat - 0.00009,
            position_origin.lon - 0.00009], {icon: icon}).bindPopup(content)
        bind_markers marker_ts
        markers_group.push(marker_ts)
        map_layer.addLayer(marker_ts)

    if position_routes.length > 0


        iteration = 0
        for pr in position_routes
            if iteration == position_routes.length - 1
                icon = 'end'
            else
                icon = 'place'

            icon = L.icon(
                iconUrl: 'icons/marker_' + icon + '.svg'
                iconSize: [44, 52]
            )
            content = pr.location_name + '<br>' + pr.location_address
            marker_ts = L.marker([pr.lat, pr.lon], {icon: icon}).bindPopup(content)
            bind_markers marker_ts
            markers_group.push(marker_ts)
            map_layer.addLayer(marker_ts)
            iteration += 1

    if position_origin != null || position_routes.length > 0

        group = new L.featureGroup(markers_group)
        setTimeout ( ->
            obj_map.fitBounds(group.getBounds().pad(0.1))
            map_layer.addTo(obj_map)
        ), 250

    if !no_route
        generate_draw_new_route()

    return

bind_markers = (m) ->
    m.on 'mouseover', ->
        this.openPopup()

    m.on 'mouseout', ->
        this.closePopup()


zoom_to_all_markers = (markers) ->
    group = new L.featureGroup(markers)
    map.fitBounds(group.getBounds())

create_row_final_travels = (o) ->
    iteration = 0
    div = ''
    $('#routes_travel_sheets').empty()
    for each_route in o
        if iteration == o.length - 1
            color = ' red flip_icon '
            icon = 'local_shipping'
            type = 'Final'
        else
            color = ' yellow darken-1 '
            icon = 'stop'
            type = 'Parada'
        iteration += 1


        i_hour = '<input value="' + each_route.start_time + '" class="timepicker_travel_sheets route_change_from inputHour" id="i' + each_route.id + '" type="time" /><label for="i' + each_route.id + '">Horario de ingreso</label>'
        f_hour = '<input value="' + each_route.end_time + '" class="timepicker_travel_sheets route_change_to inputHour" id="f' + each_route.id + '" type="time" /><label for="f' + each_route.id + '">Horario de salida</label>'

        address = '<p>' + each_route.location_name + '<br>' + each_route.location_address + '</p>'
        div = '<div class="row inputHour">'
        div += '<div class="col s5 inputHour" >'
        div += '<span class="title">' + type + '</span>' + address
        div += '</div>'
        div += '<div class="col s3 inputHour" >'
        div += i_hour
        div += '</div>'
        div += '<div class="col s3 inputHour">'
        div += f_hour
        div += '</div>'
        div += '</div>'

        head = '<li class="collection-item avatar fix_border_bottom" id="route-' + each_route.id + '">'
        icon = '<i class="material-icons circle ' + color + ' ">' + icon + '</i>'
        del = '<a href="#!" class="secondary-content del_route" data-del="' + each_route.id + '"><i class="material-icons">delete</i></a></li>'
        $('#routes_travel_sheets').append(head + icon + div + del)
    bind_time_pickers_and_delete()

###'<tr><td>' + adreess + '</td><td>' + i_hour + '</td><td>' + f_hour + '</td><td> ' + del_btn + ' </td></tr>'###

waze_api = ()-> ## just for testing...
    y1 = position_origin.lat
    x1 = position_origin.lon

    y2 = position_routes[0].lat
    x2 = position_routes[0].lon
    console.log x1, y1, x2, y2
    $.ajax '/waze/index?url=routingRequest&fx=' + x1 + '&fy=' + y1 + '&tx=' + x2 + '&ty=' + y2,
        type: 'GET',
        error: (jqXHR, textStatus, errorThrown) ->
            console.textStatus
        success: (data, textStatus, jqXHR) ->
            routes = []
            time = 0
            for waze in data.response.results
                p = waze.path
                time += waze.crossTime
                routes.push([p.y, p.x])
            L.polyline(routes, {color: 'DodgerBlue', weight: 4}).addTo(map)
            console.log data
            console.log time, time / 60

save_travel_sheet = ->
    travel_sheet.position_origin = null
    travel_sheet.position_routes = null
    travel_sheet.date_travel = $("#date_travel").val()
    travel_sheet.travel_locations_attributes = []
    $("#date_travel").val()
    if id_from_update != null
        travel_sheet.id = id_from_update
        travel_sheet.prev_id = id_from_update
    travel_sheet.travel_locations_attributes.push(position_origin)
    for r in position_routes
        travel_sheet.travel_locations_attributes.push(r)

    travel_sheet.travel_locations_attributes[travel_sheet.travel_locations_attributes.length - 1].step = 'end'
    travel_sheet.travel_name = $('#new_travel_sheets_name').val()
    travel_sheet.device_id = $('#travel_sheet_device').val()
    travel_sheet.couples_type_id = $('#travel_sheet_couple').val()
    travel_sheet.driver_id = $('#travel_sheet_driver').val()
    travel_sheet.owner_id = $('#travel_sheet_owner_cargo').val()

    if travel_sheet.travel_locations_attributes.length <= 1
        Materialize.toast "Todos los campos son requeridos", 100
        return
    travel_sheet.travel_routes_attributes = []

    for r in position_routes
        new_pos = ''
        for route in r.route
            new_pos += route.lat + ' ' + route.lon + ','

        if typeof maneuver[0] is 'object'
            maneuver[0] = JSON.stringify(maneuver)

        new_route = {
            company_id: '1'
            route_name: r.location_name
            route_geo: new_pos.slice(0, -1)
            route_duration: r.route_duration
            route_toll: false
            route_distance: r.route_distance
            maneuver: maneuver[0]
        }
        new_travel_route = {
            routes_attributes: [new_route]
        }
        travel_sheet.travel_routes_attributes.push(new_travel_route)

    Materialize.toast('<i class="material-icons">save</i> Guardando...', 5000)
    console.log travel_sheet
    $.ajax '/travel_sheets',
        type: 'POST'
        dataType: 'json'
        data: travel_sheet
        error: (jqXHR, textStatus, errorThrown) ->
            console.log textStatus
            reset()
        success: (data, textStatus, jqXHR) ->
            console.log data
            $('.toast').remove()
            if !data.response.id
                Materialize.toast(data.response, 5000)
            else
                Materialize.toast('<i class="material-icons">check</i> Hoja de viajes guardada <br>Generando vista previa...', 5000)
                search_travel_sheets()
                $('#new_travel_sheets_modal').modal('close')

                reset()
                setTimeout (->
                      win = window.open('/travel_sheets/details?ts=' + data.response.id, '_blank')
                      if win
                          win.focus()
                  ),
                  2000


reset = ->
    id_from_update = null
    $(".step").removeClass('done')
    maneuver = []
    marker_origin = null
    position_origin = null
    position_routes = []
    current_custom_search = null
    routes_lines = null
    markers = []
    travel_sheet =
        travel_name: null
        state: 'ready_to_dispatch'
        is_template: false
        device_id: null
        couples_type_id: null
        driver_id: null
        owner_id: null
        travel_locations_attributes: []
        route_id: null
        date_travel: null

    $(".start_route_address").html('')
    $("#routes_travel_sheets").html('')
    $(".start_route_hour_i").html('')
    $(".start_route_address").html('')
    $(".start_route_hour_e").html('')
    $('select').material_select()

    $("#date_travel").val(moment().format('DD/MM/YYYY')).change()
    $("#timepicker_travel_sheets_start").val(moment().format('HH:mm')).change()


initPermitStoppedZonesMap = ->
    if stoppedZones_Map != null
        return
    return if $("#stopped_zones_map").length == 0
    ######## Inicializar el mapa con las capas de Open Street Maps ############
    stoppedZones_Map = L.map('stopped_zones_map', {
        minZoom: stoppedZonesMap.minZoom,
        worldCopyJump: true
    }).setView(stoppedZonesMap.initialPosition, stoppedZonesMap.initialZoom)
    osmUrl = 'http://{s}.tile.openstreetmap.se/hydda/full/{z}/{x}/{y}.png'
    osmAttrib = ''
    osm = new L.TileLayer(osmUrl, {attributionControl: false})
    stoppedZones_Map.addLayer(osm)


    newDrawnItems = L.geoJson(
      [],
        style: (feature) ->
            color: feature.geometry.properties.color
        onEachFeature: (feature, layer) ->
            layer.bindPopup(feature.properties.name);
    ).addTo(stoppedZones_Map)

    drawControlFull = new L.Control.Draw(
        edit:
            featureGroup: newDrawnItems
            poly:
                allowIntersection: true
        draw:
            circle: true
            polyline: true
            polygon:
                allowIntersection: true
                showArea: true
                shapeOptions:
                    color: '#0000ff'
            rectangle:
                shapeOptions:
                    color: '#0000ff'
    )

    drawControlEditOnly = new L.Control.Draw(
        edit:
            featureGroup: newDrawnItems
        draw: true
    )

    stoppedZones_Map.addControl(drawControlFull)
    ##stopped_zones_table
    allowed_stopped_zones
    stoppedZones_Map.on "draw:created", (e) =>
        layer = e.layer;
        layer.addTo(newDrawnItems);
        stoppedZones_Map.removeControl(drawControlFull)
        stoppedZones_Map.addControl(drawControlEditOnly)
        layer = layer.toGeoJSON()
        layer.id = Math.floor(new Date().valueOf() * Math.random())
    ##$('#new_geo_zone_geom').val(JSON.stringify(layer.toGeoJSON()))

    stoppedZones_Map.on "draw:edited", (e) =>
        layer = le.layer.toGeoJSON()
        layer.id = Math.floor(new Date().valueOf() * Math.random())
    ##$('#new_geo_zone_geom').val(JSON.stringify(e.layer.toGeoJSON()))

    stoppedZones_Map.on "draw:deleted", (e) =>
        check = Object.keys(newDrawnItems._layers).length
        if (check == 0)
            stoppedZones_Map.removeControl(drawControlEditOnly)
            stoppedZones_Map.addControl(drawControlFull)


##$('#new_geo_zone_geom').removeAttr('value')

markersSz = []
markersSzLayer = new L.LayerGroup()
draw_layer_to_stopped_zones_map = (mapObject)->
    mapObject.eachLayer = (layer) ->
        mapObject.removeLayer layer

    markersSzLayer.addTo(mapObject)

    set_marker(false, stoppedZones_Map, markersSzLayer)


    for pr in position_routes
        route = []
        for r in pr.route
            route.push([r.lon, r.lat])
            markerSingle = L.polyline(route, {color: 'DodgerBlue', weight: 3})
            markersSzLayer.addLayer(markerSingle)


travel_sheet_resume = ->
    $('#tnname').html($('#new_travel_sheets_name').val())
    $('#tdate').html(picker.get('select', 'yyyy/mm/dd'))
    $('#tdeviceid').html($('#travel_sheet_device option:selected').text())
    $('#tct').html($('#travel_sheet_couple option:selected').text())
    $('#tdrive').html($('#travel_sheet_driver  option:selected').text())
    $('#towner').html($('#travel_sheet_owner_cargo  option:selected').text())

    $('#table_travel_sheet_resume').empty()


    tr = '<tr>'
    tr += '<td>Inicio</td>'
    tr += '<td>' + position_origin.location_name + '</td>'
    tr += '<td>' + position_origin.location_address + '</td>'
    tr += '<td>-</td>'
    tr += '<td>' + $("#timepicker_travel_sheets_start").val() + '</td>'
    tr += '</tr>'
    $('#table_travel_sheet_resume').append(tr)

    for r in position_routes
        tr = '<tr>'
        tr += '<td>Parada</td>'
        tr += '<td>' + r.location_name + '</td>'
        tr += '<td>' + r.location_address + '</td>'
        tr += '<td>' + $("#i" + r.id).val() + '</td>'
        tr += '<td>' + $("#f" + r.id).val() + '</td>'
        tr += '</tr>'
        $('#table_travel_sheet_resume').append(tr)


travel_sheet_table_principal = null
load_travel_sheet_principal_table = ->
    travel_sheet_table_principal = $('#travel_sheets_table_principal').DataTable(
        data: []
        bLengthChange: false
        processing: true
        serverSide: false
        language: {
            url: "http://cdn.datatables.net/plug-ins/1.10.13/i18n/Spanish.json"
            buttons: {
                copyTitle: 'Copiar',
                copySuccess: {
                    _: 'Copiado %d filas',
                    1: 'Copiado 1 fila'
                }
            }
        }
        order: [[1, 'asc']],
        columns: [
            {
                "data": "state",
                "className": "center_col"
            },
            {
                "mDataProp": null,
                "className": 'details-control center_col',
                "sDefaultContent": ''
            },
            {"data": "travel_name"},
            {"data": "driver.name"},
            {"data": "device.name"},
            {"data": "device.icon", "className": "center_col"},
            {"data": "owner.owner_name"},
            {"data": "date_travel"},
            {"data": "created_at"},
            {"data": "id", "className": "center_col"},
            {"data": "id", "className": "center_col"},
            {"data": "id", "className": "center_col"},
            {"data": "id", "className": "center_col", "orderable": false},
        ],
        "fnRowCallback": (nRow, aData, iDisplayIndex) ->
            date_travel = moment(aData.date_travel, 'YYYY-MM-DDTHH:mm:ssZ').format('DD/MM/YYYY')
            created_at = moment(aData.created_at, 'YYYY-MM-DDTHH:mm:ssZ').format('DD/MM/YYYY HH:mm ')

            if aData.state == 'ready_to_dispatch'
                color = 'red'
            else
                if aData.state == 'finish'
                    color = 'green'
                else
                    color = 'yellow'

            $('td:eq(0)', nRow).html '<img src="icons/' + color + '.svg">'
            $('td:eq(7)', nRow).html date_travel
            $('td:eq(8)', nRow).html created_at
            $('td:eq(9)', nRow).html '<button type="button" class="edit_travel_sheet waves-effect waves-light btn-flat" data-id="' + aData.id + '">  <i class="material-icons grey-text">mode_edit</i></button>'


            $('td:eq(10)', nRow).html '<button type="button" class="delete_travel_sheet waves-effect waves-light btn-flat" data-id="' + aData.id + '"  ><i class="material-icons grey-text">delete_forever</i></button>'
            $('td:eq(11)', nRow).html '<a target="_blank" class=" waves-effect waves-light btn-flat" href="/travel_sheets/details?ts=' + aData.id + '">  <i class="material-icons grey-text">event_note</i></a>'
            $('td:eq(12)', nRow).html state_select(aData.id, aData.state)

            src = 'devices_icons/' + aData.device.icon + '.svg'
            $('td:eq(5)', nRow).html '<img class="icon_table" src="' + src + '" alt="">'
        , "initComplete": (settings, json) ->
      $('#travel_sheets_table_principal tbody').on 'click', 'td.details-control', ->
          tr = $(this).closest('tr')
          row = travel_sheet_table_principal.row(tr)
          if row.child.isShown()
              row.child.hide()
              tr.removeClass 'shown'
          else
              row.child(format(row.data())).show()
              tr.addClass 'shown'
    )


search_travel_sheets = ->
    $(".dataTables_processing").show()

    from = travel_sheet_search_from_date.get('select', 'yyyy/mm/dd')
    to = travel_sheet_search_to_date.get('select', 'yyyy/mm/dd')

    $.ajax '/travel_sheets/search?from_date=' + from + '&to_date=' + to,
        type: 'GET'
        error: (jqXHR, textStatus, errorThrown) ->
            console.log textStatus
        success: (data, textStatus, jqXHR) ->
            console.log data
            setTimeout ( ->
                $('.background').fadeOut 'slow', ->
                    $('.loading').fadeIn 'slow', ->
                        $("body").css('background', "#fff")
                        window.dispatchEvent(new Event('resize'))

            ), 500
            travel_sheet_table_principal.clear().draw()
            if data.length > 0
                travel_sheet_table_principal.rows.add(data).draw()
                setTimeout ( ->
                    $(".delete_travel_sheet").on 'click', ->
                        delete_travel_sheet($(this).data('id'))
                    $(".edit_travel_sheet").on 'click', ->
                        edit_travel_sheet($(this).data('id'))
                    $(".change_state_travel_sheets").on 'change', ->
                        change_state_travel_sheets($(this).val(), $(this).data('id'))
                ), 300
            else
                Materialize.toast("No existen hojas de viajes", 5000)
            $(".dataTables_processing").hide()

format = (d) ->
    t = '<div class="row">'
    t += '<div class="col s11 offset-s1">'
    t += '<table>'
    t += '<tr class="td_sub_color_blue">'
    t += '<th></th>'
    t += '<th>Tipo</th>'
    t += '<th>Ubicación</th>'
    t += '<th>Dirección</th>'
    t += '<th>Hora Llegada</th>'
    t += '<th>Hora Salida</th>'
    t += '<th>Estado</th>'
    t += '</tr>'

    for tl in d.travel_locations
        t += '<tr>'
        t += '<th class="center_col"><img src="icons/' + tl.step + '.svg"></th>'
        t += '<th class="center_col">' + (if tl.step == 'start' then 'Inicio' else ((if tl.step == 'end' then 'Termino' else 'Parada'))) + '</th>'
        t += '<th>' + tl.locations[0].location_name + '</th>'
        t += '<th>' + tl.locations[0].location_address + '</th>'
        console.log tl.start_time
        t += '<th>' + moment(tl.start_time, 'YYYY-MM-DDTHH:mm:ssZ').format('HH:mm ') + '</th>'
        t += '<th>' + moment(tl.end_time, 'YYYY-MM-DDTHH:mm:ssZ').format('HH:mm ') + '</th>'
        t += '<th class="center_col">' + tl.state + '</th>'
        t += '</tr>'
    t += '</table>'
    t += '</div>'
    t += '</div>'


validate_fields_per_page = (class_name) ->
    r = true
    $(class_name).each ->
        #if $(this).val() == null
        #    Materialize.toast('Todos los campos son obligatorios', 4000)
        #    r = false
        #    return r

    return r

delete_travel_sheet = (id) ->
    if confirm('¿Seguro que desea eliminar la hoja de viajes?')
        $.ajax '/travel_sheets/' + id,
            type: 'DELETE'
            error: (jqXHR, textStatus, errorThrown) ->
                console.log textStatus
                Materialize.toast("Error al eliminar...", 5000)
            success: (data, textStatus, jqXHR) ->
                search_travel_sheets()
                Materialize.toast("Hoja de viaje eliminada", 5000)


##########EDIT################


edit_travel_sheet = (id) ->
    $.ajax '/travel_sheets/edit?ts=' + id,
        type: 'GET'
        error: (jqXHR, textStatus, errorThrown) ->
            console.log textStatus
        success: (data, textStatus, jqXHR) ->
            console.log data
            reset()
            d = data[0]
            $('#new_travel_sheets_modal').modal('open')

            setTimeout ( ->
                date_travel = moment(d.date_travel, 'YYYY-MM-DDTHH:mm:ssZ').format('DD/MM/YYYY')
                $("#new_travel_sheets_name").val(d.travel_name)
                $("#date_travel").val(date_travel).change()
                $("#travel_sheet_device").val(d.device_id).change()
                $("#travel_sheet_couple").val(d.couples_type_id).change()
                $("#travel_sheet_driver").val(d.driver_id).change()
                $("#travel_sheet_owner_cargo").val(d.owner_id).change()
                $('select').material_select()
                add_mod_routes(d)
                Materialize.updateTextFields()
            ), 500


add_mod_routes = (d) ->
    initPreviewMap 'preview_map'
    initPermitStoppedZonesMap()
    ## set route name
    id_from_update = d.id
    route = d.travel_locations[0].locations[0].location_name + '<br>' + d.travel_locations[0].locations[0].location_address
    $('.start_route_address').html route
    coors = d.travel_locations[0].locations[0].coordinate.replace('POINT (', '').replace(')', '').split(' ')
    coors = {
        x: coors[0]
        y: coors[1]
    }
    position_origin =
        state: d.travel_locations[0].state,
        step: 'start',
        start_time: moment(d.travel_locations[0].start_time, 'YYYY-MM-DDTHH:mm:ssZ').format('HH:mm'),
        end_time: moment(d.travel_locations[0].end_time, 'YYYY-MM-DDTHH:mm:ssZ').format('HH:mm'),
        id: Math.floor(new Date().valueOf() * Math.random()),
        location_name: d.travel_locations[0].locations[0].location_name
        location_address: d.travel_locations[0].locations[0].location_address
        lat: coors.x,
        lon: coors.y,
        coordinate: coors.x + ' ' + coors.y,
        is_preload: true,
        locations_attributes: [{
            location_name: d.travel_locations[0].locations[0].location_name,
            location_address: d.travel_locations[0].locations[0].location_address,
            coordinate: coors.x + ' ' + coors.y,
            company_id: '1',
            is_display: false

        }]
    $("#timepicker_travel_sheets_start").val(position_origin.end_time).change()

    iteration = 0
    for o in d.travel_locations
        if iteration != 0
            coors = o.locations[0].coordinate.replace('POINT (', '').replace(')', '').split(' ')
            coors = {
                x: coors[0]
                y: coors[1]
            }
            current_custom_search =
                state: 'ready_to_dispatch',
                step: 'place'
                start_time: moment(o.start_time, 'YYYY-MM-DDTHH:mm:ssZ').format('HH:mm'),
                end_time: moment(o.end_time, 'YYYY-MM-DDTHH:mm:ssZ').format('HH:mm'),
                id: Math.floor(new Date().valueOf() * Math.random()),
                location_name: o.locations[0].location_name
                location_address: o.locations[0].location_address
                lat: coors.x,
                lon: coors.y,
                coordinate: coors.x + ' ' + coors.y,
                is_preload: true,
                locations_attributes: [{
                    location_name: o.locations[0].location_name,
                    location_address: o.locations[0].location_address,
                    coordinate: coors.x + ' ' + coors.y,
                    is_display: false
                }]
            position_routes.push(current_custom_search)
            bind_time_pickers_and_delete()

        iteration += 1

    create_row_final_travels(position_routes)
    maneuver = []
    route = []
    iteration = 0
    for r in d.travel_routes
        position_routes[iteration].route = []
        position_routes[iteration].route_distance = r.routes[0].route_distance
        position_routes[iteration].route_duration = r.routes[0].route_duration

        route_geo = r.routes[0].route_geo.replace('LINESTRING (', '').replace(')', '').split(', ')
        maneuver.push(r.routes[0].maneuver)
        for steps in route_geo
            steps = steps.split(' ')
            route.push([steps[1], steps[0]])
            position_routes[iteration].route.push(
                lat: steps[0], lon: steps[1]
            )
        iteration++

    routes_lines = L.polyline(route, {color: 'DodgerBlue', weight: 3}).addTo(map)


change_state_travel_sheets = (state, id) ->
    $.ajax '/travel_sheets/set_state?id=' + id + '&state=' + state,
        type: 'GET'
        error: (jqXHR, textStatus, errorThrown) ->
            console.log textStatus
        success: (data, textStatus, jqXHR) ->
            console.log data
            search_travel_sheets()


state_select = (id, state) ->
    a = b = c = ''
    if state == 'ready_to_dispatch'
        a = 'selected'
    else
        if state == 'initiated'
            b = 'selected'
        else
            c = 'finish'

    s = '<select class="browser-default change_state_travel_sheets" data-id="' + id + '">'
    s += '<option value="ready_to_dispatch" data-icon="icons/red.svg" class="left circle" ' + a + '>Planificado</option>'
    s += '<option value="initiated" data-icon="icons/yellow.svg" class="left circle" ' + b + '>Iniciado</option>'
    s += '<option value="finish" data-icon="icons/green.svg" class="left circle" ' + c + '>Finalizado</option>'
    s += '</select>'

    return s


create_timeline = ->
    $('#calendar').fullCalendar
        schedulerLicenseKey: 'CC-Attribution-NonCommercial-NoDerivatives'
        now: '2017-02-09'
        theme: false,
        editable: false
        aspectRatio: 1.0
        scrollTime: '00:00'
        header:
            left: 'today prev,next'
            center: 'title'
            right: 'timelineDay,timelineThreeDays,agendaWeek,month,listWeek'
        defaultView: 'timelineDay'
        views:
            timelineThreeDays:
                type: 'timeline'
                duration:
                    days: 3
        resourceLabelText: 'Dispositivos'
        resources: [
            {
                id: 'a'
                title: 'Dispositivo A'
            }
            {
                id: 'b'
                title: 'Dispositivo B'
                eventColor: 'green'
            }
            {
                id: 'c'
                title: 'Dispositivo C'
                eventColor: 'orange'
            }
            {
                id: 'd'
                title: 'Dispositivo D'
            }
            {
                id: 'e'
                title: 'Dispositivo E'
            }
            {
                id: 'f'
                title: 'Dispositivo F'
                eventColor: 'red'
            }
            {
                id: 'g'
                title: 'Dispositivo G'
            }
        ]
        events: [
            {
                id: '1'
                resourceId: 'b'
                start: '2017-02-09T02:00:00'
                end: '2017-02-09T07:00:00'
                title: 'Viaje 1'
            }
            {
                id: '2'
                resourceId: 'c'
                start: '2017-02-09T05:00:00'
                end: '2017-02-09T22:00:00'
                title: 'Viaje 2'
            }
            {
                id: '3'
                resourceId: 'd'
                start: '2017-02-09'
                end: '2017-02-09'
                title: 'Viaje 3'
            }
            {
                id: '4'
                resourceId: 'e'
                start: '2017-02-09T03:00:00'
                end: '2017-02-09T08:00:00'
                title: 'Viaje 4'
            }
            {
                id: '5'
                resourceId: 'f'
                start: '2017-02-09T00:30:00'
                end: '2017-02-09T02:30:00'
                title: 'Viaje 5'
            }
        ]
