### Locations JS ###

### map config ###
newLocationMap =
    initialPosition: [-33.449559, -70.671239] # Santiago de Chile
    initialZoom: 14
    minZoom: 6
map = null

marker = null
initNewLocationMap = (divId) ->
    return if $("#" + divId).length == 0
    ######## Inicializar el mapa con las capas de Open Street Maps ############
    map = L.map(divId, {
        minZoom: newLocationMap.minZoom,
        worldCopyJump: true
    }).setView(newLocationMap.initialPosition, newLocationMap.initialZoom)
    #osmUrl='http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.svg'
    osmUrl = 'http://{s}.tile.openstreetmap.se/hydda/full/{z}/{x}/{y}.png'
    #http://{s}.tiles.wmflabs.org/bw-mapnik/{z}/{x}/{y}.png
    osm = new L.TileLayer(osmUrl, {attributionControl: false})

    map.addLayer(osm)
    map.invalidateSize()


### Google search api###
bindSearchBox = (inputId) ->
    infowindow = new google.maps.InfoWindow()
    input = document.getElementById inputId
    autocomplete = new google.maps.places.Autocomplete(input)

    autocomplete.addListener('place_changed', () ->
        infowindow.close()
        place = autocomplete.getPlace()
        address = ''
        if marker
            map.removeLayer marker

        if place.address_components
            address = [
                (place.address_components[0] && place.address_components[0].short_name || ''),
                (place.address_components[1] && place.address_components[1].short_name || ''),
                (place.address_components[2] && place.address_components[2].short_name || ''),
                (place.address_components[3] && place.address_components[3].short_name || ''),
                (place.address_components[5] && place.address_components[5].short_name || '')
            ].join ' '

        if place.geometry.location
            g = place.geometry.location
            $("#location_search-box-point").val g.lat() + ' ' + g.lng()

            $("#location_location_name , #location_location_name_edit").val address
            map.setView(new L.LatLng(g.lat(), g.lng()), 15)
            marker = L.marker([g.lat(), g.lng()]).addTo(map).bindPopup(address)
            map.addLayer(marker)
        else
            $("#location_location_name , #location_location_name_edit").val ''
            alert 'La ubicación no ingresada no existe'


        Materialize.updateTextFields()
        infowindow.setContent '<div><strong>' + place.name + '</strong><br>' + address

    )


### fill inputs when edit action is called ###
bindEditLocation = ->
    $(document).on 'click', '.edit_location_btn', (e)->
        e.preventDefault()
        initNewLocationMap 'location_edit_map'
        location = window.locations.filter((location) =>
            location.id == $(this).parents("tr").data("id"))[0]
        $("#edit_location_name").val location.location_name
        $("#edit_location_name").parent().addClass 'is-dirty'

        $("#location_search_box_location_edit").val location.location_address
        $("#location_location_name_edit").val location.location_address
        $("#location_search-box-point_edit").val location.coordinate
        $("#edit_location_form").attr("action", "/locations/" + location.id)


        setTimeout  (->
            if location.coordinate
                wicket = new Wkt.Wkt()
                wicket.read(location.coordinate)

                map.setView(new L.LatLng(wicket.components[0].x, wicket.components[0].y), 15)
                $("#location_search-box-point_edit").val wicket.components[0].x + ' ' + wicket.components[0].y
                marker = L.marker([wicket.components[0].x, wicket.components[0].y]).addTo(map).bindPopup(location.location_address)

                map.addLayer marker
            map.invalidateSize()
        ), 0

        Materialize.updateTextFields()


$(document).on 'ready', ->
    bindEditLocation()
    $('#new_location_modal').modal(
        ready: (modal, trigger) ->
            bindSearchBox 'location_search_box_location_new'
            initNewLocationMap 'location_new_map'
        ,
        complete: () ->
            $('.location_input').val ''
            map.remove()
    )
    $('#edit_location_modal').modal(
        ready: (modal, trigger) ->
            bindSearchBox 'location_search_box_location_edit'
        ,
        complete: () ->
            $(".location_input").val ''
            map.remove()
    )




