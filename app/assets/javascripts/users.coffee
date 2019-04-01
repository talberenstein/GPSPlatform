$ ->



  $("#user_company_id").on 'change', ->

    value = $("#user_company_id").val()
    selectbox2 = $('#user_groups_id')
    $.ajax '/companies/' + value + '/groups',
      type: 'GET'
      error: (jqXHR, textStatus, errorThrown) ->
        console.log textStatus
      success: (data, textStatus, jqXHR) ->
        console.log data
        selectbox2.empty()
        $.each data, (index, value) ->
          #append a option
          opt = $('<option/>')
          # value is an array: [:id, :name]
          opt.attr('value', value[0])
          #set text
          opt.text(value[1])
          # append to select
          console.log selectbox2
          opt.appendTo(selectbox2)
          $('select').material_select()




