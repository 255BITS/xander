class Xander
  choose : (id) ->
    result = []
    for choice in @choices
      result.push choice[0]
    result

module.exports = new Xander()

