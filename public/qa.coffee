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
    equal 0, $("#test1").attr('data-variant-slot'), "test1 issue"
    equal 1, $("#test2").attr('data-variant-slot'), "test2 issue"
    ok $("#test3").attr('data-variant-slot') > 1, "test3 issue"
  test "Ensuring proper chosen variant name", ->
    ok $("#test1").attr('data-variant-chosen').length > 0, 'variant-chosen not populated'

    

