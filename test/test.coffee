assert     = require 'assert'
flashcards = require '../src/flashcards'

test "say answer is correct when it's correct", ->
  noun =
    id: 1
    spanish: "equipaje"
    english_options: ["luggage", "baggage"]
  assert.equal true, flashcards.isEnglishAnswerAcceptable("luggage", noun)
