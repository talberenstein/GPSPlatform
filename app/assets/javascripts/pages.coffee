$(document).on 'ready', ->

    $('.selectMenuOption').on 'click', ->
        $('.selectMenuOption').removeClass 'activeButtonTop'
        $(this).addClass 'activeButtonTop'
        $('.optionsMenus').hide()
        id = $(this).data('menu')
        $('#' + id).show()

    ### EVALUAR EL USO DE SELECTIZE...###
    ###$('.selectize').selectize()###

    ### Por ahora se usa material_select###
    $('select').material_select();


    $('.modal:not(.map)').modal()
    $('.datepicker').pickadate(
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

    )

    $('.timepicker').pickatime(
        autoclose: true
        twelvehour: false
        default: '00:00:00'
        container: 'body'
        donetext: 'Aceptar'
    )

    $('.collapsible').collapsible()
    $('.button-collapse').sideNav(
        menuWidth: 300
        edge: 'left'
        closeOnClick: true
        draggable: true
    )

    $('.sidetab a').on 'click', (e) ->
        e.preventDefault()
        $('li.tab').find("a[href='" + $(e.target).attr('href') + "']").click()



