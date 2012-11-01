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
    
    

