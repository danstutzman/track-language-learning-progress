assert = require 'assert'

test 'should return -1 when not present', ->
  assert.equal -1, [1,2,3].indexOf(4)