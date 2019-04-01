# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

route_map = null

$(document).on 'ready', ->
    events()
    $('select').material_select()
    if window.location.href.indexOf('informations/index') != -1
        $('.selectMenuOption').hide()




events = ->

    ##side menu reports
    $(".report-menu").on 'click', ->
        $(".report_tab").hide()
        $("#report_tab_"+$(this).data('menu')).show()
        route_map = null

    $('.datepicker_information').pickadate(
        default: 'now'
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
        format: 'yyyy/mm/dd',
        onStart: ->
            date = new Date()
            $('.datepicker_information').val(date.getFullYear() + '/' + parseInt(date.getMonth()+1) + '/' + date.getDate())
    )

    $('.timepicker_information_start').pickatime({
        twelvehour: false,
        donetext: 'Ok',
        now: 'Hora Actual'
        autoclose: false,
    })

    $('.timepicker_information_start').val('00:00')
    $('.timepicker_information_final').val('23:59')

    $('.timepicker_information_final').pickatime({
        default: '23:59',
        twelvehour: false,
        donetext: 'OK',
        autoclose: false,
        vibrate: true

    })



    ###setTimeout ( ->
        $('.dt-button').toggleClass('dt-button','btn')
        setTimeout ( ->
            $('.buttons-flash .buttons-colvis').addClass('btn')
        ), 2500
    ), 2500###
