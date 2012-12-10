getParameterByName = (name) ->
  name = name.replace(/[\[]/, "\\\[").replace(/[\]]/, "\\\]")
  regexS = "[\\?&]" + name + "=([^&#]*)"
  regex = new RegExp(regexS)
  results = regex.exec(window.location.search)
  return "" if(results == null)
  decodeURIComponent(results[1].replace(/\+/g, " "))


class XanderClient
  constructor: ->
    @first_slot = 1
    @slot_number = 1
  showVariantBar : ->
    console.log("Show variant bar")
    $('body').prepend """
      <div id='__variants' style='padding-left: 10%; width: 100%; background: black; color: white; border-bottom: 5px solid #CCC'>
        <table id='__variantTable'></table>
      </div>
"""
    # Element variants
    $("*[data-variant]").parent().each (i, x) =>
      variants = $(x).find("> [data-variant]")
      options = ""
      variants.each (i, y) =>
        options += " <td><button onclick='xander.showVariant(\"#{@titleFor(x)}\",\"#{$(y).attr('data-variant')}\"); return false'>#{$(y).attr('data-variant')}</button></td>"
      console.log($(x).attr('id'))

      $('#__variantTable').append("<tr><th>#{@titleFor(x)}</th>#{options}</tr>")
      @slot_number+=1

    # CSS variants
    $("*[data-css-variants]").each (i, x) =>
      variants = $(x).attr('data-css-variants').split(' ')
      options = ""
      console.log("2", variants)
      $(variants).each (i, y) =>
        options += " <td><button onclick='xander.showCssVariant(\"#{@titleFor(x)}\",\"#{y}\"); return false'>#{y}</button></td>"

      $('#__variantTable').append("<tr><th>#{@titleFor(x)}</th>#{options}</tr>")
      @slot_number+=1
    @slot_number = @first_slot

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
    all_choices.each (i, x) =>
      variants = $(x).find("> [data-variant]")
      variants.hide()
      # the user forgot to name the section or containing div
      if !$(x).attr('id')
        console.error("Could not find parent id for data-variant")
        console.error x
        return
      $(x).attr('data-variant-slot', @slot_number)
      chosen = $(variants[parseInt(Math.random() * variants.length)]).show()
      $(x).attr('data-variant-chosen', chosen.attr('data-variant'))
      @slot_number += 1
    if(all_choices.length > 5)
      console?.log "You have too many variants to track with Google Analytics!  Google Analytics limits the number of custom variable slots to 5."

  chooseCssVariant: ->
    all_choices = $("[data-css-variants]")
    all_choices.each (i, x) =>
      if !$(x).attr('id')
        console.error("data-css-variants element is missing id")
        console.error x
        return
      options = $(x).attr('data-css-variants').split(' ')
      option = options[parseInt(Math.random() * options.length)]
      $(options).each (j, k) ->
        $(x).removeClass k
      $(x).addClass option
      $(x).show().attr 'data-variant-slot', @slot_number
      $(x).show().attr 'data-variant-chosen', option
      @slot_number += 1

  wireGoals: ->
    $("*[data-goal]").each (i, x) ->
      x = $(x)
      goal = x.attr('data-goal')
      if(x.is("a") || (x.is("input") && x.attr('type') == 'submit' ) || x.is("button")) 
        x.click ->
          xander.goalReached(goal)
      else if x.is("form")
        x.submit ->
          xander.goalReached(goal)
      else
        console?.error("[Xander] Error: no idea what to do with the goal defined on this element:", x)
        console?.error( "Supported types are a tags, submit inputs, forms.  Please check http://xander.io for more information")

  apiKeyPath : (key) ->
    "http://variants.xander.io/#{key}/#{encodeURIComponent(window.location.host+window.location.pathname)}/chosen.js"

  apiKey : (key) ->
    $("head").append("<script src='#{@apiKeyPath(key)}'></script>")

  goalReached : (goal) ->
    _gaq.push ['_trackPageview', goal]
    return false if @trackingDisabled
    i = new Image() 
    i.src = @trackingPixelGoalPath(goal)
    return true

  titleFor : (e) ->
    id = $(e).attr 'id'
    return "Slot #"+@slot_number unless id
    id

  # Structure of each variant has both:
  #   data-variant-slot and data-variant-chosen (name)
  #   id is used to set the custom variable.
  callAnalytics : ->
    $("*[data-variant-slot]").each (i, x) =>
      chosen = $(x).attr('data-variant-chosen')
      @slot_number = $(x).attr('data-variant-slot')
      title = @titleFor(x)
      _gaq.push ['_setCustomVar', parseInt(@slot_number), title,  chosen, 2 ] 

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
        variants = $target.attr("data-css-variants")?.split(' ')
        if(variants?.length > 1)
          for variant, i in variants
            if $target.hasClass(variant)
              variants.splice i, 1
              $target.removeClass variant
              break
          chosen = variants[parseInt(Math.random() * variants.length)]
          $target.addClass(chosen)
          $target.attr('data-variant-chosen', chosen)

          
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

  allVariants : ->
    result = {}
    $("*[data-variant-chosen]").each (i, x) ->
      $x = $(x)
      id = $x.attr('id')
      result[id] = []

      if $x.attr("data-css-variants")
        result[id] = $x.attr('data-css-variants').split(' ')
      else
        $x.find("[data-variant]").each (j, y) ->
          result[id].push $(y).attr("data-variant")

    return result

  goals : ->
    $.map $("*[data-goal]"), (x) ->
      $(x).attr("data-goal")

  # no I dont want any cool information about my variants
  disableTrackingPixel : ->
    @trackingDisabled = true

  addTrackingPixel : ->
    return false if @trackingDisabled
    i = new Image() 
    i.src = @trackingPixelPath()
    true

  uuid : ->
    return @uid if @uid
    @uid = localStorage.getItem('uuid')
    return @uid if @uid

    # courtesy of the insane genius broofa at http://stackoverflow.com/questions/105034/how-to-create-a-guid-uuid-in-javascript
    @uid = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace /[xy]/g, (c) =>
      r = Math.random()*16|0
      v = if c == 'x' then r else (r&0x3|0x8)
      v.toString(16)
    
    localStorage.setItem('uuid', @uid)
    @uid

  trackingPixelPath : ->
    url = "http://track.xander.io/impression.gif?"
    url += "url=#{encodeURIComponent(window.location.host+window.location.pathname)}"
    url += "&chosen=#{encodeURIComponent(JSON.stringify(@variant()))}"
    url += "&all=#{encodeURIComponent(JSON.stringify(@allVariants()))}"
    url += "&goals=#{encodeURIComponent(JSON.stringify(@goals()))}"
    url += "&user=#{encodeURIComponent(@uuid())}"
    url

  trackingPixelGoalPath : (goal) ->
    url = "http://track.xander.io/goal.gif?"
    url += "url=#{encodeURIComponent(window.location.host+window.location.pathname)}"
    url += "&user=#{encodeURIComponent(@uuid())}"
    url += "&goal=#{encodeURIComponent(goal)}"
    url += "&chosen=#{encodeURIComponent(JSON.stringify(@variant()))}"
    url

xander = new XanderClient()

$ ->
  xander.slot_number = xander.first_slot
  xander.showVariantBar() if getParameterByName('showVariants') == 'true'
  xander.chooseVariant()
  xander.chooseCssVariant()
  xander.wireGoals()
  xander.callAnalytics() unless getParameterByName('showVariants') == 'true'
  xander.addTrackingPixel()

window.xander = xander

