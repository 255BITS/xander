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
  test "Reroll always rerolls a different variant than the current one", ->
    oldVariant = xander.variant()
    xander.reroll()
    anythingDifferent = false
    for key, val of xander.variant()
      anythingDifferent = anythingDifferent || oldVariant[key] != val
    ok anythingDifferent, "something must be different!"
  test "Reroll takes a target", ->
    $target = $($("*[data-variant-slot]")[0])
    chosen = $target.attr("data-variant-chosen")
    xander.reroll($target)
    ok $target.attr("data-variant-chosen") != chosen, "data-variant does not get updated on reroll target"

