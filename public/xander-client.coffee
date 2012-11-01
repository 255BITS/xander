class XanderClient
  first_slot = 0
  chooseVariant: ->
    slot_number = first_slot
    all_choices = $("*[data-variants]")
    all_choices.each (i, x) ->
      slot_number += 1
      variants = $(x).find("> [data-variant]")
      variants.hide()
      $(variants[parseInt(Math.random() * variants.length)]).show().attr('data-variant-chosen', slot_number)
      slot_number += 1
    if(all_choices.length > 5)
      console?.log "You have too many variants to track!  Google Analytics limits the number of custom variable slots to 5."
        
  callAnalytics : ->
    $("*[data-variants]").each (i, x) ->
      chosen = $(x).find('*[data-variant-chosen]')[0] 
      slot_number = $(chosen).attr('data-variant-chosen')
      title = $(x).attr 'data-variants' || ("slot_"+slot_number)
      variant = $(chosen).attr('data-variant')
      _gaq.push ['_setCustomVar', slot_number, title,  variant, 2 ] 

xander = new XanderClient()

$ ->
  xander.chooseVariant()
  xander.callAnalytics()

window.xander = xander

