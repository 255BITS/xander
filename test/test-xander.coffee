assert = require 'assert'
xander = require '../xander-api'
journal = require '../../../lib/journal'

assert.arrayEqual = (one, two) ->
  same = true
  assert.fail() if one.length != two.length
  i = 0
  for o in one
    assert.equal(one[i],two[i])
    i+= 1

assert.arrayNotEqual = (one, two) ->
  return true if one.length != two.length
  i = 0
  for o in one
    assert one[i] != two[i], "Arrays #{one} and #{two}  not equal"
    i+= 1

  

describe 'Xander (multivariate) creation', () ->
  beforeEach (done) ->
    xander.choices = [['a','b'],['c'],['d','e','f']]
    done()
    
  describe "A user with a given IP address", () ->
    it 'should give a specific association', (done) ->
      assert.equal 3, xander.choose('uniqueId').length
      assert.arrayEqual( xander.choose('uniqueId')[0], xander.choose('uniqueId')[0])
      done()

    it 'should give a different association with a different ID', (done) ->
      assert.arrayNotEqual( xander.choose('uniqueId')[0], xander.choose('otherId')[0])
      done()
