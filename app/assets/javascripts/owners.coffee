# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$(document).on 'ready', ->
    bindEditOwner()

bindEditOwner = ->
    $(document).on 'click', '.edit_owner_btn', (e)->
        e.preventDefault()

        owner = window.owners.filter((owner) =>
            owner.id == $(this).parents("tr").data("id"))[0]

        $("#edit_owner_name").val(owner.owner_name)
        $("#edit_owner_name").parent().addClass('is-dirty')
        $('#edit_owner_location_id').val(owner.location_id) if $('#edit_owner_location_id')[0]
        $('#edit_owner_location_id').material_select()
        $("#edit_owner_form").attr("action", "/owners/" + owner.id)
        Materialize.updateTextFields()