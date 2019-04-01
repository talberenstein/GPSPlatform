report_f_date = report_i_date = null
activities_reports_table = null
c_date_i = c_date_f = c_time_i = c_time_f = null
$(document).on 'ready', ->
  $('#search_activities_report').on 'click', ->
    do_activities_report()

  activities_reports_table = $('#activities_reports_table').DataTable(
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
    ]
    columns: [
      {"data": "device_name"},
      {"data": "date_from"},
      {"data": "distance"},
      {"data": "trips"},
      {"data": "drive_hours"},
      {"data": "stopoff_hours"},
      {"data": "stopon_hours"}
    ]
  )
  Materialize.updateTextFields();


do_activities_report = ->
  c_date_i = $('#report_i_date_activities').val()
  c_date_f = $('#report_f_date_activities').val()
  console.log c_date_i + ' to ' + c_date_f
  Materialize.toast('Consultando Base de Datos', (1000) * 60 * 5)
  $.ajax '/information/report_activities',
    type: 'GET'
    data: {
      from_date: c_date_i
      to_date: c_date_f
      from_time: '00:00:00'
      to_date: c_date_f
      to_time: '23:59:59'
      imeis: $("#activities_devices").val()
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

      activities_reports_table.clear().draw()
      activities_reports_table.rows.add(data).draw()
      console.log data