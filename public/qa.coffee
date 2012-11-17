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
  test "Goals should be enabled on form button clicks", ->
    $("#test4btn").click()
    ok _gaq[_gaq.length-1][0] == "_trackPageview", "Wrong event type in _gaq for goal"
    ok _gaq[_gaq.length-1][1] == "test4", "Wrong goal name in _gaq"
  test "Goals should be enabled on form submits", ->
    $("#test5form").submit()
    ok _gaq[_gaq.length-1][0] == "_trackPageview", "Wrong event type in _gaq for goal"
    ok _gaq[_gaq.length-1][1] == "test5", "Wrong goal name in _gaq"
  test "Goals should be enabled on <a> tags", ->
    $("#test6atag").click()
    ok _gaq[_gaq.length-1][0] == "_trackPageview", "Wrong event type in _gaq for goal"
    ok _gaq[_gaq.length-1][1] == "test6", "Wrong goal name in _gaq"

  # TODO test "Javascript onclick events should still occur", ->

    

