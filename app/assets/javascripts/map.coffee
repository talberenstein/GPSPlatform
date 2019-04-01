imei_global = null
device_id = null
command_text = null
mapConfig =
    domId: 'mapid'
    initialPosition: [-33.449559, -70.671239] # Santiago de Chile
    initialZoom: 13
    minZoom: 2

map = trace = trackingDeviceImei = null

icon_auto = L.icon({
    iconUrl: image_path('auto.svg'),
    iconSize: [40, 40],
    iconAnchor: [10, 10]
})
icon_bus = L.icon({
    iconUrl: image_path('bus.svg'),
    iconSize: [40, 40],
    iconAnchor: [20, 20]
})
icon_camion = L.icon({
    iconUrl: image_path('camion.svg'),
    iconSize: [40, 40],
    iconAnchor: [20, 20]
})
icon_camion34 = L.icon({
    iconUrl: image_path('camion34.svg'),
    iconSize: [40, 40],
    iconAnchor: [20, 20]
})
icon_camioneta = L.icon({
    iconUrl: image_path('camioneta.svg'),
    iconSize: [40, 40],
    iconAnchor: [20, 20]
})
icon_van = L.icon({
    iconUrl: image_path('van.svg'),
    iconSize: [40, 40],
    iconAnchor: [20, 20]
})

moveToTab2 = (id) ->
    window.open(
      id,
        '_blank'
    )


moveToTab = (id) ->
    $('a[href="' + id + '"]').click()

bindCommandClick = (e) ->
  $(document).on 'click', '#new_command', (e) ->
    e.preventDefault
    device = (window.devices.filter (d) ->
      parseInt(d.imei) == imei_global
    )[0]
    if device
      #last registered command
      command_requests = (window.command_request.filter (cr) ->
        cr.device_id == device.id
      )[0]
#      console.log device
#      console.log command_requests
#      $("#device_command_text").html(command_requests.command_text)
#      $("#device_command_date").html(command_requests.time_request)
      $("#device_name_command").html("  "+device.name)
      $("#device_imei_command").html(device.imei)
      last_position = window.devices_positions[imei_global]
      $('#send_command_on').on 'click', (e) ->
        r = confirm("¿Está seguro que desea ENCENDER la máquina "+device.name+"?\nEsta operación no se puede cancelar una vez enviada.\n\nPresione Cancelar para terminar.\nPresione Ok para aceptar.")
        if r
          $('#send_command_off').tooltip('close')
          $('#send_command_on').tooltip('close')
          bindSendCommand(device.id, device.name, device.imei, 'cortar')
        else
          $('#send_command_off').tooltip('close')
          $('#send_command_on').tooltip('close')
          $('.modal').modal('close')

      $('#send_command_off').on 'click', (e) ->
        r = confirm("¿Está seguro que desea APAGAR la máquina "+device.name+"?\nEsta operación no se puede cancelar una vez enviada.\n\nPresione Cancelar para terminar.\nPresione Ok para aceptar.")
        if r
          $('#send_command_off').tooltip('close')
          $('#send_command_on').tooltip('close')
          bindSendCommand(device.id, device.name, device.imei, 'encender')
        else
          $('#send_command_off').tooltip('close')
          $('#send_command_on').tooltip('close')
          $('.modal').modal('close')

#console.log command_requests.command_text
      ###if command_requests.command_text
        $(".params_device_last_command").html(">>> Last command: "+command_requests.command_text)
      else
        $(".params_device_last_command").html(">>> Last command: Doesnt Exist")
      $(".params_device_status").html(">>> Status: "+command_requests.status)###



      ### $('#send_command_off').one 'click', (e) ->
        r = confirm("¿Está seguro que desea APAGAR la máquina "+device.name+"?\nEsta operación no se puede cancelar una vez enviada.\n\nPresione Cancelar para terminar.\nPresione Ok para aceptar.")
        if r
          $('#send_command_off').tooltip('close')
          bindSendCommand(device.id, device.name, 'cortar')
        else
          $('#send_command_off').tooltip('close')
          $('.modal').modal('close')###


      ###$('#send_command_on').one 'click', (e) ->
        r = confirm("¿Está seguro que desea ENCENDER la máquina "+device.name+"?\nEsta operación no se puede cancelar una vez enviada.\n\nPresione Cancelar para terminar.\nPresione Ok para aceptar.")
        if r
          $('#send_command_on').tooltip('close')
          bindSendCommand(device.id, device.name, 'prender')
        else
          $('#send_command_on').tooltip('close')
          $('.modal').modal('close')###

    else
      alert("Primero debe seleccionar un vehículo en el panel izquierdo")
      $('#new_device_command_modal').modal('close')




    bindSendCommand = (device_id, device_name, device_imei, command) ->
        #window.channel.push(canal,'device_id: device_id')
        $('#send_command_modal').html(' <div><b>Enviando Petición<b></div><div style="margin-left: 40%; margin-top: 25%;">  <div class="preloader-wrapper big active">
            <div class="spinner-layer spinner-green-only">
              <div class="circle-clipper left">
                <div class="circle"></div>
              </div><div class="gap-patch">
                <div class="circle"></div>
              </div><div class="circle-clipper right">
                <div class="circle"></div>
              </div>
            </div>
            </div>  </div>  ')
        Materialize.toast('Envío de Comando Activo', (1000) * 60 * 5)
        $.ajax '/command_requests',
          type: 'POST'
          dataType: 'json'
          data: {
            device_id: device_id
            command_text: command
          }
          error: (jqXHR, textStatus, errorThrown) ->
            $('.toast').remove()
            Materialize.toast('Ocurrió un error...', 4000)
            console.log textStatus
          success: (data, textStatus, jqXHR) ->
            $('.toast').remove()
            window.channel2.push('send', {imei: device_imei})
            $('#send_command_modal').html(' <div><b>Enviando Petición<b>  <font color="green">OK!</font>   </div>\
            <div><b>Esperando Respuesta<b> </div>\
            <div style="margin-left: 40%; margin-top: 25%;">  <div class="preloader-wrapper big active">
            <div class="spinner-layer spinner-green-only">
              <div class="circle-clipper left">
                <div class="circle"></div>
              </div><div class="gap-patch">
                <div class="circle"></div>
              </div><div class="circle-clipper right">
                <div class="circle"></div>
              </div>
            </div>
            </div>  </div>  ')
            Materialize.toast('Envío de Comando Activo', (1000) * 60 * 5)
            $('#send_command_modal').html(' <div><b>Enviando Petición<b>  <font color="green">OK!</font>   </div>\
            <div><b>Esperando Respuesta<b>   <font color="red">Waiting...</font> </div>\
            <div style="margin-left: 40%; margin-top: 25%;">  <div class="preloader-wrapper big active">
            <div class="spinner-layer spinner-green-only">
              <div class="circle-clipper left">
                <div class="circle"></div>
              </div><div class="gap-patch">
                <div class="circle"></div>
              </div><div class="circle-clipper right">
                <div class="circle"></div>
              </div>
            </div>
            </div>  </div>  ')
            window.channel2.on 'send', (msg) ->
              console.log msg
              req = msg
              #IF RESPUESTA VALIDA O NO VALIDA Y MOSTRAR
              $('#send_command_modal').html(' \
              <div><b>Enviando Petición<b>  <font color="green">OK!</font>   </div>\
              <div><b>Esperando Respuesta<b>   <font color="green">OK!</font> </div>\
              <div><b>Analizando Respuesta<b> <font color="green">OK!</font> </div>\
              <br>\
              <div id="request"></div> \
                  <a class="modal-action modal-close waves-effect waves-green btn-flat" id="btn_close">
                  Cerrar
                  </a>')
              $(document).on 'click', '#btn_close', (e) ->
                $('#send_command_modal').modal('close')
              $('#request').html(req)
              $('.toast').remove()
              $(document).one 'click', '#command_again', (e) ->
                $('#new_device_command_modal').reload()
              Materialize.toast('Envío Correcto', (1000) * 5)

              #   $('#new_device_command_modal').html(req)
            if !data.response.id
              console.log data.response






bindPathReportClick = (e) ->
    $(document).on 'click', '.path_report_map_btn', (e) ->
        e.preventDefault
        #console.log imei_global
        moveToTab2 '/informations/info/?device_id='+imei_global
        console.log $("#path_devices").selectize()[0].selectize.setValue($(e.target).parent().data("imei"))

bindDeviceRowClick = ->
    $(document).on 'click', 'a.device-show', (e) ->
        e.preventDefault()
        ###$('a.device-show').parents("tr").css('background-color', 'white')
        $(this).parents("tr").css('background-color', 'lightblue')###

        imei = $(this).data('imei')
        imei_global = imei
        #console.log imei_global
        device = window.devices_positions[imei]
        return unless device

        updateDeviceInfo(device)
        map.setView(device.coords, 17)

bindTrackCheckbox = ->
    $(document).on 'click', '.track_checkbox', ->
        if !$(this).hasClass 'tracking'
            $('.track_checkbox').removeClass('tracking').children().removeClass 'Blink'
            $(this).addClass('tracking').children().addClass 'Blink'
            trackDevice()
        else
            setTimeout ( ->
                map.setZoom(16)
            ), 1000
            $('.track_checkbox').removeClass('tracking').children().removeClass 'Blink'


        return

trackDevice = ->
    map.removeLayer trace if trace

    trackingDeviceImei = $('.tracking').data('imei')

    trackingDevice = window.devices_positions[trackingDeviceImei]
    #console.log trackingDevice
    return unless trackingDevice

    #console.log "traking_device" + trackingDevice
    updateDeviceInfo(trackingDevice)

    position = trackingDevice.coords
    #console.log position
    map.panTo(position)

    setTimeout ( ->
        map.setZoom(15)
    ), 500


    return
    if trackingDevice.pointList.length > 1
        trackingDevice.pointList.sort (a, b) ->
            return a.date - b.date
        trackingDevice.pointList = _.takeRight(trackingDevice.pointList, 5)

        pointList = trackingDevice.pointList.map (point) ->
            point.coords

        trace = new L.polyline(pointList, {
            color: 'blue',
            weight: 3,
            opacity: 0.6
            smoothFactor: 1
        })

        trace.addTo(map)

updateDeviceRow = (device) ->

    d = new Date();
    if device.velocity > 5
      $(".engine_status_"+device.imei).attr("src", "/map/engine_green.svg?"+d.getTime())
    else if device.ignition && device.velocity < 5
      $(".engine_status_"+device.imei).attr("src", "/map/engine_yellow.svg?"+d.getTime())
    else if !device.ignition
      $(".engine_status_"+device.imei).attr("src", "/map/engine_red.svg?"+d.getTime())

    if device.gps_valid
      $(".gps_status_"+device.imei).attr("src", "/map/gps_green.svg?"+d.getTime())
    else
      $(".gps_status_"+device.imei).attr("src", "/map/gps_red.svg?"+d.getTime())

    $(".gprs_status_"+device.imei).attr("src", "/map/gprs_green.svg?"+d.getTime())


    ###row = $("#show_checkbox_" + device.imei)
    engine = row.find(".engine_status")
    engine.html("")###

    ### row = $("tr.map_device[data-imei='" + device.imei + "']")
    gps_valid = row.find(".gps_valid")
    gps_valid.html(if device.gps_valid then "<img src='" + image_path('/map/gps_green.svg') + "' />" else "<img src='" + image_path('/map/gps_red.svg') + "' />")
    gprs_online = row.find(".gprs_online")
    gprs_online.html("<img src='" + image_path('/map/gprs_green.svg') + "' />")
    $("#device_info_map #gprs_status_img").html("<img src='" + image_path('/map/gprs_green.svg') + "' />") if device.imei == trackingDeviceImei
    engine_status = row.find(".engine_status")
    engine_status_img = image_path('/map/engine_green.svg') if device.velocity > 5
    engine_status_img = image_path('/map/engine_red.svg') if device.ignition && device.velocity <= 5
    engine_status_img = image_path('/map/engine_yellow.svg') if !device.ignition && device.velocity <= 5
    engine_status.html("<img src='" + engine_status_img + "' />")
    console.log engine_status###

deviceDisconnected = (device) ->
    row = $("tr.map_device[data-imei='" + device.imei + "']")
    gprs_online = row.find(".gprs_online")
    gprs_online.html("<img src='" + image_path('/map/gprs_red.svg') + "' />")

updateDeviceInfo = (device) ->
    #console.log "estoy en updateDeviceInfo"
    de = window.devices.filter((d) ->
        d.imei == device.imei)[0]

    console.log (device)

    if device.panic==false then $("#device_info_map #panic").html("Pánico Desactivado") else if device.panic==true then $("#device_info_map #panic").html("Pánico Activo")
    if device.door==false then $("#device_info_map #door").html("Puerta Cerrada") else if device.door==true then $("#device_info_map #door").html("Puerta Abierta")
    if device.unhook==false then $("#device_info_map #unhook").html("Desenganche Desactivado") else if device.unhook==true then $("#device_info_map #unhook").html("Desenganche Activo")

    $("#date").html(moment(device.date).format('DD/MM/YYYY'))
    $("#time").html(moment(device.date).format('HH:mm:ss'))
    $("#velocity").html(Math.round(device.velocity) + " km/h")
    $(".name").html(device.name)
    #$("#device_info_map #gprs_status_img").html("<img src='" + image_path('/map/gprs_red.svg') + "' />")
    #$("#device_info_map #gps_status_img").html(if device.gps_valid then "<img src='" + image_path('/map/gps_green.svg') + "' />" else "<img src='" + image_path('/map/gps_red.svg') + "' />")


    geocodeService = L.esri.Geocoding.geocodeService()
    geocodeService.reverse().latlng(device.coords).run (error, result) ->
        #console.log result.address
        $("#address").html(result.address.Address + ', ' + result.address.Neighborhood + ', ' + result.address.Subregion) if result and result.address
        #console.log address

updateDeviceMarker = (device) ->
    return unless device

    de = window.devices.filter((d) ->
        d.imei == device.imei)[0]

    return unless de

    map.removeLayer de.marker if de.marker

    ###
      return unless $('.map_device[data-imei="'+device.imei+'"] .show_checkbox').is(":checked")
    ###

    return unless device.checked
    de.marker = L.marker(device.coords, {
        icon: eval("icon_#{de.icon}"),
        rotationAngle: device.direction-90
    }).bindTooltip(de.name, {permanent: false,direction: 'top',sticky: true}).addTo(map)
    de.marker.on 'click', ->
        updateDeviceInfo(device)


bindShowCheckbox = ->
    $('.show_checkbox').on 'change', ->
        imei = $(this).parents("tr").data("imei").toString()

        de = window.devices.filter((d) ->
            d.imei == imei)[0]

        return unless de

        if !$(this).is(":checked")
            map.removeLayer de.marker if de.marker
        else
            updateDeviceMarker(window.devices_positions[imei])


resizeMap = ->
    actualHeight = $(window).height() - 100
    maxHeight = $(window).height() * $(window).width() / 1000
    maxHeight = if maxHeight < actualHeight then maxHeight else actualHeight
    $(".mapGeneric").height maxHeight
    map.invalidateSize

resizeMap_tracking = ->
  actualHeight = $(window).height() - 40
  maxHeight = $(window).height() * $(window).width() / 1000
  maxHeight = if maxHeight < actualHeight then maxHeight else actualHeight
  $(".mapGeneric").height maxHeight
  map.invalidateSize

resizeMap2 =  ->
  actualHeight = $(window).height() - 280
  maxHeight = $(window).height() * $(window).width() / 1000
  maxHeight = if maxHeight < actualHeight then maxHeight else actualHeight
  $(".mapGeneric").height maxHeight
  map.invalidateSize

$('#resume_open').on 'click',  ->
  resizeMap2()

$('#resume_close').on 'click',  ->
  resizeMap()

$('#btn_tracking').on 'click',  ->
  resizeMap_tracking()


$(document).on 'ready', ->

    return if $("#" + mapConfig.domId).length == 0
    ######## Inicializar el mapa con las capas de Open Street Maps ############
    map = L.map(mapConfig.domId, {
        minZoom: mapConfig.minZoom,
        worldCopyJump: true
    }).setView(mapConfig.initialPosition, mapConfig.initialZoom)
    #osmUrl='http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.svg'
    osmUrl = 'http://{s}.tile.openstreetmap.se/hydda/full/{z}/{x}/{y}.png'
    #http://{s}.tiles.wmflabs.org/bw-mapnik/{z}/{x}/{y}.png
    osm = new L.TileLayer(osmUrl, {attributionControl: false})

    map.addLayer(osm)
    ###$.jstree.defaults.core.themes.variant = "large"###

    $('#jstree').jstree(
      {
        core: {
            themes: {
                name: 'proton',
                responsive: true
            }
        }, checkbox: {
            three_state: true,
            whole_node: false,
            tie_selection: false
        }, search: {
            case_insensitive: true,
            show_only_matches: true
        }, plugins: [
            'checkbox',
            'search',
            'sort'
        ]
    }).on("ready.jstree check_node.jstree uncheck_node.jstree", (e, data) ->
        imeis = []
        console.log "JULIOOOO! DATA JSTREE"
        if data.node.children.length == 0
            imei = data.node.data.imei.toString()
            imeis.push(imei)
        else
            for i in data.node.children
                if  i != undefined
                    i = i.replace('show_checkbox_','')
                    imeis.push(i.toString())
                else
        for deviceImei in imeis
            de = window.devices.filter((d) -> d.imei == deviceImei)[0]
            return unless de

            if !data.node.state.checked
                if window.devices_positions[deviceImei]
                    window.devices_positions[deviceImei].checked = false
                    map.removeLayer de.marker if de.marker
            else
                if window.devices_positions[deviceImei]
                    window.devices_positions[deviceImei].checked = true
                    updateDeviceMarker(window.devices_positions[deviceImei])
                else
                    Materialize.toast('No hay información para '+deviceImei, 4000)
    ).on('select_node.jstree', (e, data) ->
        countSelected = data.selected.length;
        if countSelected > 1
            data.instance.deselect_node( [ data.selected[0] ] )

    )


    $('#searchDevice').keyup () ->
        $('#jstree').jstree('search', $(this).val())


    ###legend = L.control({position: 'topleft'})

    legend.onAdd = (map) ->
      div = L.DomUtil.create('div', 'info legend')
      div.innerHTML = '  <a class="btn-floating waves-effect waves-light cyan darken-3"><i class="material-icons">add</i></a>'
      div


    legend.addTo(map);###


    _.each window.devices_positions, (device) ->
        updateDeviceMarker(device)

    bindTrackCheckbox()
    bindDeviceRowClick()
    bindPathReportClick()
    bindCommandClick()
    bindShowCheckbox()
    resizeMap()

    setTimeout(->
        map.invalidateSize()
    , 1000)

    $('a[href="#tracking"]').on 'click', ->
        setTimeout(->
            map.invalidateSize()
        , 100)

    $(window).on "resize", ->
        resizeMap()


    $('.collaptable').aCollapTable(
        startCollapsed: true
        addColumn: false
        plusButton: '<span></span>'
        minusButton: '<span></span>'
    )

    $('.collapse-group').on 'click', ->
        $(this).parents("tr").find(".act-more").click()
        if $(this).parents("tr").hasClass('act-tr-expanded')
            $(this).next().replaceWith("<img src='" + image_path('icono-selectormenuactivado.png') + "' style='width: 20px;padding: 5px;'/>")
        else
            $(this).next().replaceWith("<img src='" + image_path('icono-selectormenu.png') + "' style='width: 20px;padding: 5px;'/>")

    $('.show_group_checkbox').on 'click', ->
        checked = $(this).prop('checked')
        $.each $('tr.map_device[data-parent="group_' + $(this).data("group-id") + '"] .show_checkbox'), (i, el) ->
            $(el).prop('checked', checked)
            $(el).trigger('change')


    # Escuchar mensajes de cambio de posición
    window.channel.on "new_position", (msg) ->
        #console.log msg
        device = window.devices_positions[msg.imei] || {pointList: []}
        device.imei = msg.imei
        device.device_type = msg.device_type
        device.coords = msg.geom.coordinates.slice().reverse()
        device.velocity = msg.velocity
        device.direction = msg.direction
        device.altitude = msg.altitude
        device.odometer = msg.odometer
        device.gps_valid = msg.gps_valid
        device.ignition = msg.ignition
        device.date = new Date(msg.gps_date)
        device.pointList.push({date: device.date, coords: device.coords})
        device.panic = msg.input_1
        device.door = msg.input_2
        device.unhook = msg.input_3

        d = new Date();
        $(".img_gprs").attr("src", "/map/gprs_green.svg?"+d.getTime())


        row = $("tr.map_device[data-imei='" + device.imei + "']")
        engine_status = row.find(".engine_status")
        console.log "row.find" + engine_status
        if device.velocity > 5
        	console.log "device.velocity: " + device.velocity
        	engine_status_img = "<img src='/map/engine_green.svg' />"
        	#engine_status.append( "<td>"+ engine_status_img +"</td>")
        	$("a.device_show.iconList[data-imei='" + device.imei + "']").find(".engine_status").attr("src", "/map/engine_green.svg?"+d.getTime())


        updateDeviceRow(device)
        return unless device.gps_valid

        window.devices_positions[msg.imei] = device

        updateDeviceMarker(device)
        #console.log "asdf"
        #console.log trackingDeviceImei
        #console.log device.imei
        trackDevice()
        ###if trackingDeviceImei == device.imei ###


    window.channel.on "device_disconnected", (msg) ->
        deviceDisconnected(msg)


    window.channel.on "command_request", (msg) ->
        console.log msg
        command_request = msg
        console.log command_request.status
        setLogRequest(command_request)


