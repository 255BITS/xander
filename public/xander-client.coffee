# Xander is MIT licensed

storage = null
# Old browser support for localStorage.  Taken and modified from:
# https://github.com/wojodesign/local-storage-js
if typeof window.localStorage != 'object'
  # non-standard: Firefox 2+
  if typeof window.globalStorage == 'object'
    try
      storage = window.globalStorage
  else
    # non-standard: IE 5+
    div = document.createElement("div")
    attrKey = "localStorage"
    div.style.display = "none"
    document.getElementsByTagName("head")[0].appendChild div
    if div.addBehavior
      div.addBehavior "#default#userdata"
      storage = 
        setItem: (key, value) ->
          div.load attrKey
          div.setAttribute key, value
          div.save attrKey
        getItem: (key) ->
          div.load attrKey
          div.getAttribute key
      div.load attrKey
else
  storage = window.localStorage

error = (e) -> console?.error e

# This will parse the query string and return a param within it.
# Used for showVariants=true
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
  showVariantBar : ->
    $('body').prepend """
      <div id='__variants' style='width: 100%; background: black; color: white; border-bottom: 5px solid #CCC'>
        <div style='padding-left: 10%'>
          <table id='__variantTable'></table>
        </div>
      </div>
"""
    # Element variants
    $("*[data-variant]").parent().each (i, x) =>
      variants = $(x).find("> [data-variant]")
      options = ""
      variants.each (i, y) =>
        options += " <td><button onclick='xander.showVariant(\"#{@titleFor(x)}\",\"#{$(y).attr('data-variant')}\"); return false'>#{$(y).attr('data-variant')}</button></td>"

      $('#__variantTable').append("<tr><th>#{@titleFor(x)}</th>#{options}</tr>")
      @slot_number+=1

    # CSS variants
    $("*[data-css-variants]").each (i, x) =>
      variants = $(x).attr('data-css-variants').split(' ')
      options = ""
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

  chooseVariant: (force) ->
    all_choices = $("*[data-variant]").parent()
    all_choices.each (i, x) =>
      variants = $(x).find("> [data-variant]")
      variants.hide()
      # the user forgot to name the section or containing div
      if !$(x).attr('id')
        error("Could not find parent id for data-variant")
        error x.outerHTML
        return
      $(x).attr('data-variant-slot', @slot_number)
      if @xanderIOVariants && !force
        variant = @xanderIOVariants[$(x).attr('id')]
        $selected = $(x).find "> [data-variant=#{variant}]"
        if $selected.length == 0
          $selected = $(variants[0])

        chosen = $selected.show()
        $(x).attr('data-variant-chosen', chosen.attr('data-variant'))
      else
        chosen = $(variants[parseInt(Math.random() * variants.length)]).show()
        $(x).attr('data-variant-chosen', chosen.attr('data-variant'))
      @slot_number += 1

  chooseCssVariant: (force) ->
    all_choices = $("[data-css-variants]")
    all_choices.each (i, x) =>
      if !$(x).attr('id')
        error("data-css-variants element is missing id")
        error x.outerHTML
        return
      options = $(x).attr('data-css-variants').split(' ')
      if @xanderIOVariants && !force
        option = @xanderIOVariants[$(x).attr('id')]
        # Make sure the data-css option actually exists on the page.  
        # This prevents useVariant() from invalid selections.
        if !option || $.inArray(option, options) == -1
          option = options[0]
      else
        option = options[parseInt(Math.random() * options.length)]
      $(options).each (j, k) ->
        $(x).removeClass k
      $(x).addClass option
      $(x).show().attr 'data-variant-slot', @slot_number
      $(x).show().attr 'data-variant-chosen', option
      @slot_number += 1

  updateVariant : (force=false) ->
    @slot_number = @first_slot
    @chooseVariant(force)
    @chooseCssVariant(force)
    @onVariantChosenCallback(@variant()) if @onVariantChosenCallback

  onVariantChosen : (callback) ->
    @onVariantChosenCallback = callback

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
        error("[Xander] Error: no idea what to do with the goal defined on this element:", x)
        error( "Supported types are a tags, submit inputs, forms.  Please check http://xander.io for more information")

  apiKeyPath : (key) ->
    "http://255bits.cloudant.com/variants/_design/variants/_show/next/#{encodeURIComponent(window.location.host+window.location.pathname)}.js"

  apiKey : (key) ->
    timeout = true
    window.setTimeout(() =>
      return unless timeout
      @addTrackingPixel()
      xander.updateVariant()
    , 1000)
    $.getScript(@apiKeyPath(key)).done () =>
      timeout = false
      @addTrackingPixel()
    @_apiKey = key

  goalReached : (goal) ->
    @goalsPush(goal)
    sync = => @syncGoals()
    setTimeout(sync, 100)
    return true

  clearGoals : () ->
    storage.setItem("goalsToSync","")

  goalsPush : (goal) ->
    goals = @goalsToSync()
    if goals
      goals.push(goal)
    else
      goals = [goal]
    storage.setItem("goalsToSync", goals.join(';'))
    goals

  goalsToSync : () ->
    result = storage.getItem("goalsToSync")
    return [] unless result
    return result.split(';') unless result == ''
    return []

  syncGoals : () ->
    for goal in @goalsToSync()
      _gaq?.push ['_trackPageview', goal]
      continue if @trackingDisabled # No Xander.io tracking for those who opt-out
      i = new Image() 
      i.src = @trackingPixelGoalPath(goal)
    @clearGoals()

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
      slot = parseInt($(x).attr('data-variant-slot'), 10)
      title = @titleFor(x)
      _gaq?.push ['_setCustomVar', slot, title,  chosen, 2 ] if slot <= 5 # Google Analytics only supports 5 custom variables. 

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
      xander.updateVariant(true)

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
    return true if @trackingExists
    @trackingExists = true
    i = new Image() 
    i.src = @trackingPixelPath()
    true

  uuid : ->
    return @uid if @uid
    @uid = storage.getItem('uuid')
    return @uid if @uid

    # courtesy of the insane genius broofa at http://stackoverflow.com/questions/105034/how-to-create-a-guid-uuid-in-javascript
    @uid = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace /[xy]/g, (c) =>
      r = Math.random()*16|0
      v = if c == 'x' then r else (r&0x3|0x8)
      v.toString(16)
    
    storage.setItem('uuid', @uid)
    @uid

  trackingPixelPath : ->
    url = "http://track.xander.io/impression.gif?"
    url += "url=#{encodeURIComponent(window.location.host+window.location.pathname)}"
    url += "&chosen=#{encodeURIComponent(@stringify(@variant()))}"
    url += "&all=#{encodeURIComponent(@stringify(@allVariants()))}"
    url += "&goals=#{encodeURIComponent(@stringify(@goals()))}"
    url += "&user=#{encodeURIComponent(@uuid())}"
    url += "&apiKey=#{@_apiKey}" if @_apiKey
    url += "&variantType=#{@variantType}" if @variantType
    url += "&referral=#{encodeURIComponent(document.referral)}" if document.referral
    url += "&experiment=#{encodeURIComponent(@experiment)}" if @experiment
    url

  trackingPixelGoalPath : (goal) ->
    url = "http://track.xander.io/goal.gif?"
    url += "url=#{encodeURIComponent(window.location.host+window.location.pathname)}"
    url += "&user=#{encodeURIComponent(@uuid())}"
    url += "&goal=#{encodeURIComponent(goal)}"
    url += "&chosen=#{encodeURIComponent(@stringify(@variant()))}"
    url += "&apiKey=#{@_apiKey}" if @_apiKey
    url += "&variantType=#{@variantType}" if @variantType
    url += "&referral=#{encodeURIComponent(document.referral)}" if document.referral
    url += "&experiment=#{encodeURIComponent(@experiment)}" if @experiment
    url

  # UseVariant is expected to be called before $(document).ready by xander.io
  useVariant : (choices, variantType) ->
    @xanderIOVariants = choices
    @variantType = variantType
    $ =>
      @updateVariant()
      @callAnalytics()

  # Json stringify from http://stackoverflow.com/questions/5093582/json-is-undefined-error-in-ie-only
  stringify : (obj, force=false) ->
    return JSON.stringify(obj) if JSON?.stringify && !force
    t = typeof (obj)
    if t isnt "object" or obj is null
      # simple data type
      obj = "\"" + obj + "\""  if t is "string"
      String obj
    else

      # recurse array or object
      n = undefined
      v = undefined
      json = []
      arr = (obj and obj.constructor is Array)
      for n of obj
        v = obj[n]
        t = typeof (v)
        if t is "string"
          v = "\"" + v + "\""
        else v = @stringify(v)  if t is "object" and v isnt null
        json.push ((if arr then "" else "\"" + n + "\":")) + String(v)
      ((if arr then "[" else "{")) + String(json) + ((if arr then "]" else "}"))
        


xander = new XanderClient()

$ ->
  shouldShowVariants = getParameterByName('showVariants') == 'true'
  xander.slot_number = xander.first_slot
  xander.showVariantBar() if shouldShowVariants 
  unless xander._apiKey
    xander.updateVariant()
    xander.addTrackingPixel()
  
  xander.wireGoals()
  xander.callAnalytics() unless shouldShowVariants
  xander.syncGoals() # Sync goals tracked from previous pages

window.xander = xander

