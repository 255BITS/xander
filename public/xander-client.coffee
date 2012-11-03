getParameterByName = (name) ->
  name = name.replace(/[\[]/, "\\\[").replace(/[\]]/, "\\\]")
  regexS = "[\\?&]" + name + "=([^&#]*)"
  regex = new RegExp(regexS)
  results = regex.exec(window.location.search)
  return "" if(results == null)
  return decodeURIComponent(results[1].replace(/\+/g, " "))


class XanderClient
  first_slot = 0
  slot_number = 0
  showVariantBar : ->
    console.log("Show variant bar")
    $('body').prepend """
      <div id='__variants' style='width: 100%; background: black; color: white; border-bottom: 5px solid #CCC'>
      </div>
"""
    # Element variants
    $("*[data-variant]").parent().each (i, x) ->
      variants = $(x).find("> [data-variant]")
      options = ""
      variants.each (i, y) ->
        options += " <button onclick='xander.showVariant(\"#{$(x).attr('id')}\",\"#{$(y).attr('data-variant')}\"); return false'>#{$(y).attr('data-variant')}</button>"
      
      $('#__variants').append("<div><span>#{$(x).attr('id')}</span><span>#{options}</span></div>")

    # CSS variants
    $("*[data-css-variants]").each (i, x) ->
      variants = $(x).attr('data-css-variants').split(' ')
      options = ""
      $(variants).each (i, y) ->
        options += " <button onclick='xander.showCssVariant(\"#{$(x).attr('id')}\",\"#{y}\"); return false'>#{y}</button>"

      $('#__variants').append("<div><span>#{$(x).attr('id')}</span><span>#{options}</span></div>")

  showVariant: (name, subname) ->
    variants = $("##{name}")
    $(variants).find("> [data-variant]").hide()
    variant = $(variants).find("> [data-variant='#{subname}']").show()

  showCssVariant: (id, klass) ->
    el = $("##{id}")
    variants = el.attr('data-css-variants').split(' ')
    $(variants).each (i, y) ->
      el.removeClass y
    el.addClass klass

  chooseVariant: ->
    all_choices = $("*[data-variant]").parent()
    all_choices.each (i, x) ->
      variants = $(x).find("> [data-variant]")
      variants.hide()
      $(x).attr('data-variant-slot', slot_number)
      chosen = $(variants[parseInt(Math.random() * variants.length)]).show()
      $(x).attr('data-variant-chosen', chosen.attr('data-variant'))
      slot_number += 1
    if(all_choices.length > 5)
      console?.log "You have too many variants to track!  Google Analytics limits the number of custom variable slots to 5."

  chooseCssVariant: ->
    all_choices = $("*[data-css-variants]")
    all_choices.each (i, x) ->
      options = $(x).attr('data-css-variants').split(' ')
      $(x).addClass options[parseInt(Math.random() * options.length)]
      $(x).show().attr 'data-variant-slot', slot_number
      slot_number += 1

  # Structure of each variant has both:
  #   data-variant-slot and data-variant-chosen (name)
  #   id is used to set the custom variable.
  callAnalytics : ->
    $("*[data-variant-slot]").each (i, x) ->
      chosen = $(x).attr('data-variant-chosen')
      slot_number = $(x).attr('data-variant-slot')
      title = $(x).attr 'id' || ("slot_"+slot_number)
      _gaq.push ['_setCustomVar', slot_number, title,  chosen, 2 ] 

xander = new XanderClient()

$ ->
  xander.showVariantBar() if getParameterByName('showVariants') == 'true'
  xander.slot_number = xander.first_slot
  xander.chooseVariant()
  xander.chooseCssVariant()
  xander.callAnalytics() unless getParameterByName('showVariants') == 'true'

window.xander = xander

