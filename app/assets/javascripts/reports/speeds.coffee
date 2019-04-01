report_f_date = report_i_date = null
speed_reports_table = null
c_date_i = c_date_f = c_time_f = c_time_i = null
route_map = null
cord_x_ini = null
cord_y_ini = null
aux = 0
$(document).on 'ready', ->
  $('#search_speed_report').on 'click', ->
    do_speed_report()
  $("#report_tab_playback").show()
  $("#report_tab_speed").show()
  $('#modal_map_information').modal(
    dismissible: false,
  )


  speed_reports_table = $('#speed_reports_table').DataTable(
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
    dom: 'Bfrtip',
    buttons: [
      'copyFlash',
      'csvFlash',
      'excelFlash',
      {
        extend: 'print',
        exportOptions: {
          columns: ':visible'
        }
      },
      'colvis',
      {
        extend: 'pdf',
        message: 'GESTSOL - Reporte generado a las ' + new Date()
        orientation: 'landscape',
        exportOptions: {
          columns: [0, 1, 2, 3, 4, 5]
        }
      }
    ],
    columns: [
      {"data": "device_name"},
      {"data": "driver_name"},
      {"data": "date_from"},
      {"data": "place_from"},
      {"data": "date_to"},
      {"data": "place_to"},
      {"data": "max_speed"},
      {"data": "duration_in_time"},
      {"data": "duration_in_km"},
      {"data": "to_graph"},
    ],
    "fnRowCallback": (nRow, aData, iDisplayIndex) ->
      $('td:eq(9)', nRow).html '<button type="button" class="show_path_information btn waves-effect waves-light" data-id="' + aData.id + '">  <i class="material-icons">mode_edit</i></button>'
  )


##row.child(format(row.data())).show()


do_speed_report = ->
  c_date_i = $('#report_i_date').val()
  c_date_f = $('#report_f_date').val()
  c_time_i = $('#report_i_time').val()
  c_time_f = $('#report_f_time').val()
  console.log c_time_i + ' to ' + c_time_f
  Materialize.toast('Consultando Base de Datos', (1000) * 60 * 5)


  velocity_limit = $('#report_f_speed').val()
  imeis = $("#speeds_devices").val()
  limit = $('#report_limit_speed').val()


  $.ajax '/information/report_speeds',
    type: 'GET'
    data: {
      from_date: c_date_i
      from_time: c_time_i
      to_date: c_date_f
      to_time: c_time_f
      velocity_limit: velocity_limit
      imeis: imeis
    }
    error: (jqXHR, textStatus, errorThrown) ->
      Materialize.toast('Error al listar los datos...', 4000)
      console.log textStatus
      $('.toast').remove()
    success: (data, textStatus, jqXHR) ->
      $('.toast').remove()
      Materialize.toast('Consulta Realizada', (1000) * 2)
      if data.error
        Materialize.toast(data.error, 5000)
        return

      setTimeout ( ->
        $('.show_path_information').on 'click', ->
          tr = $(this).closest('tr')
          row = speed_reports_table.row(tr)
          draw_map(row.data())
      ), 500
      speed_reports_table.clear().draw()
      speed_reports_table.rows.add(data).draw()
      console.log data

draw_map = (d) ->

  console.log "in1"
  $('#modal_map_information').modal 'open'

  setTimeout ( ->

    if route_map
      route_map.remove()
      console.log 'in'

    route_map = L.map('route_map', {
      minZoom: 7,
      worldCopyJump: true
    }).setView([-33.449559, -70.671239], 17)
    osmUrl = 'http://{s}.tile.openstreetmap.se/hydda/full/{z}/{x}/{y}.png'

    osm = new L.TileLayer(osmUrl, {attributionControl: true})
    route_map.addLayer(osm)

    route_map.eachLayer = (layer) ->
      route_map.removeLayer layer


    route = []

    for l in d.array_1
      console.log l
      lx = l.geom.replace('POINT (', '').replace(')', '').split(' ')
      if aux == 0
        cord_x_ini = lx[1]
        cord_y_ini = lx[0]
        aux = 1
      console.log l.velocity
      route.push([lx[1], lx[0]])
      route_map.setView([lx[1], lx[0]], 14)
      icon = L.icon(
        iconUrl: '/icons/marker_start.svg'
        iconSize: [40, 40]
      )
      icon_2 = L.icon(
        iconUrl: '/icons/marker_end.svg'
        iconSize: [40, 40]
      )


      if parseInt(l.velocity) >= 0
        markerSingle = L.polyline(route, {color: 'red', weight: 4})





    ##route_map.addLayer(marker_ts)
    marker_ts_ini = L.marker([cord_x_ini, cord_y_ini], {icon: icon})
    aux = 0
    marker_ts = L.marker([lx[1], lx[0]], {icon: icon_2})
    route_map.addLayer(marker_ts)
    route_map.addLayer(marker_ts_ini)
    route_map.addLayer(markerSingle)
  ), 500





