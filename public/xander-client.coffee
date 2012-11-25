getParameterByName = (name) ->
  name = name.replace(/[\[]/, "\\\[").replace(/[\]]/, "\\\]")
  regexS = "[\\?&]" + name + "=([^&#]*)"
  regex = new RegExp(regexS)
  results = regex.exec(window.location.search)
  return "" if(results == null)
  return decodeURIComponent(results[1].replace(/\+/g, " "))


class XanderClient
  first_slot = 1
  slot_number = 1
  showVariantBar : ->
    console.log("Show variant bar")
    $('body').prepend """
      <div id='__variants' style='padding-left: 10%; width: 80%; background: black; color: white; border-bottom: 5px solid #CCC'>
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
      # the user forgot to name the section or containing div
      if !$(x).attr('id')
        console.error("Could not find parent id for data-variant")
        console.error x
        return
      $(x).attr('data-variant-slot', slot_number)
      chosen = $(variants[parseInt(Math.random() * variants.length)]).show()
      $(x).attr('data-variant-chosen', chosen.attr('data-variant'))
      slot_number += 1
    if(all_choices.length > 5)
      console?.log "You have too many variants to track!  Google Analytics limits the number of custom variable slots to 5."

  chooseCssVariant: ->
    all_choices = $("[data-css-variants]")
    all_choices.each (i, x) ->
      if !$(x).attr('id')
        console.error("data-css-variants element is missing id")
        console.error x
        return
      options = $(x).attr('data-css-variants').split(' ')
      option = options[parseInt(Math.random() * options.length)]
      $(x).addClass option
      $(x).show().attr 'data-variant-slot', slot_number
      $(x).show().attr 'data-variant-chosen', option
      slot_number += 1

  # Structure of each variant has both:
  #   data-variant-slot and data-variant-chosen (name)
  #   id is used to set the custom variable.
  callAnalytics : ->
    $("*[data-variant-slot]").each (i, x) ->
      chosen = $(x).attr('data-variant-chosen')
      slot_number = $(x).attr('data-variant-slot')
      title = $(x).attr 'id' || ("slot_"+slot_number)
      _gaq.push ['_setCustomVar', parseInt(slot_number), title,  chosen, 2 ] 

  # This rerolls the page into any variant except the current one
  # This is more useful for demo or testing than prod.
  reroll : ($target) ->
    if $target
      chosen = $target.attr("data-variant-chosen")
      variants = $target.find("> [data-variant]")
      if variants.length > 1
        variants.hide()
        for variant, i in variants
          if $(variant).attr('data-variant')==chosen
            variants.splice i, 1
            break
        $chosen = $(variants[parseInt(Math.random() * variants.length)]).show()
        $target.attr('data-variant-chosen', $chosen.attr('data-variant'))

    else
      @chooseVariant()
      @chooseCssVariant()


      

  # Returns the current variant in JSON form
  variant : ->
    results = {}
    $("*[data-variant-slot]").each (i, x) ->
      chosen = $(x).attr('data-variant-chosen')
      title = $(x).attr 'id' || ("slot_"+slot_number)
      results[title]=chosen
    results


xander = new XanderClient()

$ ->
  xander.showVariantBar() if getParameterByName('showVariants') == 'true'
  xander.slot_number = xander.first_slot
  xander.chooseVariant()
  xander.chooseCssVariant()
  xander.callAnalytics() unless getParameterByName('showVariants') == 'true'

window.xander = xander

