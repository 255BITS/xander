$ ->
  test "Only one subsection is visible in a given section", ->
    numberVisible = 0
    $("#test1 > [data-variant]").each (i,x) ->
      numberVisible += 1 if $(x).is(":visible")
    ok numberVisible, 1, "Only one variant should be visible."

  test "Nested subsections work correctly", ->
    numberVisible = 0
    $("#test2sub1 > [data-variant]").each (i,x) ->
      numberVisible += 1 if $(x).is(":visible")
    ok numberVisible, 1, "nested variant test2sub2 broken."
    
  test "Class variants should be supported.", ->
    ok !($("#test3").hasClass("class1") && $("#test3").hasClass("class2")), "test3 has 2 variants!"
    ok ($("#test3").hasClass("class1") || $("#test3").hasClass("class2")), "test3 has no variants!"

  test "Ensuring proper slot order", ->
    equal 1, $("#test1").attr('data-variant-slot'), "test1 issue"
    equal 2, $("#test2").attr('data-variant-slot'), "test2 issue"
    ok $("#test3").attr('data-variant-slot') > 1, "test3 issue"
    
  test "Ensuring proper chosen variant name", ->
    ok $("#test1").attr('data-variant-chosen').length > 0, 'variant-chosen not populated'
    ok $("#test3").attr('data-variant-chosen').length > 0, 'css-variant-chosen not populated'

  # Goals
  test "Goals should be enabled on form button clicks", ->
    $("#test6btn").click()
    ok _gaq[_gaq.length-1][0] == "_trackPageview", "Wrong event type in _gaq for goal"
    ok _gaq[_gaq.length-1][1] == "test6", "Wrong goal name in _gaq"
  test "Goals should be enabled on form submits", ->
    $("#test7form").submit()
    ok _gaq[_gaq.length-1][0] == "_trackPageview", "Wrong event type in _gaq for goal"
    ok _gaq[_gaq.length-1][1] == "test7", "Wrong goal name in _gaq"
  test "Goals should be enabled on <a> tags", ->
    $("#test8atag").click()
    ok _gaq[_gaq.length-1][0] == "_trackPageview", "Wrong event type in _gaq for goal"
    ok _gaq[_gaq.length-1][1] == "test8", "Wrong goal name in _gaq"
  test "Goals should work on <button tags>", ->
    $("#test9button").click()
    ok _gaq[_gaq.length-1][0] == "_trackPageview", "eventtype for button tag incorrect."
    ok _gaq[_gaq.length-1][1] == 'test9', 'Wrong goal name in _gaq'

  test "Goals should serialize", ->
    ok xander.goals().length > 0, "There are no goals listed."

  # TODO test "Javascript onclick events should still occur", ->

  test "Reroll always rerolls a different variant than the current one", ->
    oldVariant = xander.variant()
    xander.reroll()
    anythingDifferent = false
    for key, val of xander.variant()
      anythingDifferent = anythingDifferent || oldVariant[key] != val
    ok anythingDifferent, "something must be different!"

  test "Reroll takes a target", ->
    $target = $($("[data-variant-slot]")[0])
    chosen = $target.attr("data-variant-chosen")
    xander.reroll($target)
    ok $target.attr("data-variant-chosen") != chosen, "data-variant does not get updated on reroll target"

  test "Reroll works with data-css-variants", ->
    $target = $($("[data-css-variants]")[0])
    chosen = $target.attr("data-variant-chosen")
    ok $target.hasClass(chosen), "css variant does not have the correct class added."
    xander.reroll($target)
    ok !$target.hasClass(chosen), "css variant has same class as before reroll"
    ok $target.attr("data-variant-chosen") != chosen, "data-css-variants does not get updated on reroll target"

  test "Nested data-css-variants", ->
    $obj = $("#nested1")
    hasClass = $obj.hasClass('a') || $obj.hasClass('b') || $obj.hasClass('c')
    ok hasClass, "nested1 missing class"

  test "Subnested data-css-variants", ->
    $obj = $("#nested2")
    hasClass = $obj.hasClass('a') || $obj.hasClass('b') || $obj.hasClass('c')
    ok hasClass, "nested2 missing class"

  test "Subsubnested-null data-css-variants", ->
    $obj = $("#nested3null")
    len = $obj[0].classList.length
    ok len == 0, "data-css-variants with no arguments should be ignored"

  test "unnamed sections should raise an error", ->
    $obj = $("[data-test5]")
    ok !$obj.is(':visible'), "unnamed sections should be hidden"

  test "unnamed data-css-variants should raise an error", ->
    $obj = $("[data-test5-css]")
    ok !$obj.is(':visible'), "unnamed sections should be hidden"
    ok !$obj.hasClass('a'), "unnamed sections should be hidden"
    ok !$obj.hasClass('b'), "unnamed sections should be hidden"

  test "all your variants are belong to us", ->
    ok JSON.stringify(xander.allVariants()["test1"]) == JSON.stringify(['a', 'b', 'c']), "Content Variants aren't represented."
    ok JSON.stringify(xander.allVariants()["test3"]) == JSON.stringify(["class1", "class2"]), "CSS Variants aren't represented."

  test "uuid should be generated.", -> 
    ok xander.uuid().length > 1, "UUID should be generated"
  test "uuid should be stored in localstorage", ->
    ok localStorage.getItem('uuid').length > 1, "UUID should be stored."

  # xander.io integration
  test "API key path correctness", ->
    ok xander.apiKeyPath("test") == "http://variants.xander.io/localhost%3A2255%2Fqa.html.js"

  test "Adding an API key includes xander professional edition", ->
    scripts = $("script").length
    xander.apiKey("test")
    ok xander._apiKey == 'test', "Not keeping track of api key"
    ok scripts + 1 == $("script").length, "Not generating script tag for API"

  test "Add a tracking pixel on variants chosen", ->
    ok xander.addTrackingPixel() == true , "Couldn't add tracking pixel"

  test "Disable tracking pixel works", ->
    xander.disableTrackingPixel()
    ok xander.addTrackingPixel() == false, "Tracking pixel has become omnipresent!!"

  test "Goal tracking should have uuid.", ->
    ok /user=/.test(xander.trackingPixelGoalPath('test')), "Goal Tracking pixel doesn't include user token"
    ok /goal=/.test(xander.trackingPixelGoalPath('test')), "Goal Tracking pixel doesn't include user token"
    ok /apiKey=/.test(xander.trackingPixelGoalPath('test')), "Tracking pixel doesn't include user token"

  test "Tracking pixel path should include relevant information", ->
    ok /url=/.test(xander.trackingPixelPath()), "Tracking pixel doesn't include URL"
    ok /chosen=/.test(xander.trackingPixelPath()), "Tracking pixel doesn't include chosen variants"
    ok /all=/.test(xander.trackingPixelPath()), "Tracking pixel doesn't include variant options"
    ok /goals=/.test(xander.trackingPixelPath()), "Tracking pixel doesn't include goals"
    ok /user=/.test(xander.trackingPixelPath()), "Tracking pixel doesn't include user token"
    ok /apiKey=/.test(xander.trackingPixelPath()), "Tracking pixel doesn't include user token"

  test "xander#useVariant should use a data variant if specified", ->
    xander.useVariant {useVariant:'b'}, 'best'
    xander.chooseVariant()
    xander.chooseCssVariant()
    ok xander.variantType == 'best', 'useVariant second argument is where the traffic is sourced from (test or best)'
    ok /apiKey=/.test(xander.trackingPixelPath()), "Tracking pixel doesn't include user token"
    ok /apiKey=/.test(xander.trackingPixelGoalPath()), "Tracking pixel doesn't include user token"
    ok $("#useVariant").attr('data-variant-chosen') == 'b', "chose wrong data variant"

  test "xander#useVariant should use a data-css variant if a css variant is specified", ->
    xander.useVariant {useVariantCSS:'b'}
    xander.chooseVariant()
    xander.chooseCssVariant()
    ok $("#useVariantCSS").attr('data-variant-chosen') == 'b', "chose wrong CSS variant"

  test "xander#useVariant should default to the 0-th entry if no variant is chosen", ->
    xander.useVariant {}
    xander.chooseVariant()
    xander.chooseCssVariant()
    ok $("#useVariant").attr('data-variant-chosen') == 'a', "0-th index data variant not chosen"
    
  test "xander#useVariant should default to the 0-th entry if no css variant is chosen", ->
    xander.useVariant {}
    xander.chooseVariant()
    xander.chooseCssVariant()
    ok $("#useVariantCSS").attr('data-variant-chosen') == 'a', "0-th index CSS entry not chosen"

  test "xander#useVariant invalid data variant should default to 0-th index", ->
    xander.useVariant {useVariant:'non-exist'}
    xander.chooseVariant()
    xander.chooseCssVariant()
    ok $("#useVariant").attr('data-variant-chosen') == 'a', "0-th index data variant not chosen"

   test "xander#useVariant invalid data css variant should default to 0-th index", ->
    xander.useVariant {useVariantCSS:'non-exist'}
    xander.chooseVariant()
    xander.chooseCssVariant()
    ok $("#useVariant").attr('data-variant-chosen') == 'a', "0-th index data variant not chosen"
    
