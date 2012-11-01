getParameterByName = (name) ->
  name = name.replace(/[\[]/, "\\\[").replace(/[\]]/, "\\\]")
  regexS = "[\\?&]" + name + "=([^&#]*)"
  regex = new RegExp(regexS)
  results = regex.exec(window.location.search)
  return "" if(results == null)
  return decodeURIComponent(results[1].replace(/\+/g, " "))


class XanderClient
  first_slot = 0
  showVariantBar : ->
    console.log("Show variant bar")
    $('body').prepend """
      <div id='__variants' style='width: 100%; background: black; color: white; border-bottom: 5px solid #CCC'>
      </div>
"""
    $("*[data-variants]").each (i, x) ->
      variants = $(x).find("> [data-variant]")
      options = ""
      variants.each (i, y) ->
        options += " <a onclick='xander.showVariant(\"#{$(x).attr('data-variants')}\",\"#{$(y).attr('data-variant')}\")'>#{$(y).attr('data-variant')}</a>"
      
      $('#__variants').append("<div><span>#{$(x).attr('data-variants')}</span><span>#{options}</span></div>")

  showVariant: (name, subname) ->
    variants = $("*[data-variants='#{name}']")
    $(variants).find("> [data-variant]").hide()
    variant = $(variants).find("> [data-variant='#{subname}']").show()

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
  xander.showVariantBar() if getParameterByName('showVariants') == 'true'
  xander.chooseVariant()
  xander.callAnalytics()

window.xander = xander

