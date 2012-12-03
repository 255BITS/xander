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

  test "API key path correctness", ->
    ok xander.apiKeyPath("test") == "http://variants.xander.io/test/localhost%3A2255%2Fqa.html/chosen.js"

  test "adding an API key includes xander professional edition", ->
    scripts = $("script").length
    xander.apiKey("test")
    ok scripts + 1 == $("script").length, "Not generating script tag for API"
