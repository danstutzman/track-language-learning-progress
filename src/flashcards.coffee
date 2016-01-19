{LocalStorage} = require 'node-localstorage'
Promise        = require 'bluebird'
FlashcardsDb   = require './FlashcardsDb'

testTranslationToEnglish = (noun) ->
  questionAt = Date.now()
  console.log "Press space when you remember the English translation of:\n\n" +
    "#{noun.spanish}\n"
  new Promise (resolve, reject) ->
    setNextKeypressDeferred().promise.then (key) ->
      # round responseDelay to nearest tenth of second
      responseDelay = Math.floor((Date.now() - questionAt) / 100) * 100 / 1000
      expected = ("\"#{english}\"" for english in noun.english_options).join(' or ')
      console.log "Answer is: #{expected}"
      console.log "Was your answer correct? (Y/N)"
      setNextKeypressDeferred().promise.then (key2) ->
        correct = (key2 == 'y' or key2 == 'Y')
        response =
          nounId: noun.id
          correct: correct
          questionAt: Math.floor(questionAt / 1000)
          responseDelay: responseDelay
        stdin.pause() # allow program to exit
        resolve response

if module == require.main
  nextKeypressDeferred = []
  setNextKeypressDeferred = ->
    [resolve, reject] = [null, null]
    promise = new Promise (resolve_, reject_) ->
      [resolve, reject] = [resolve_, reject_]
    nextKeypressDeferred[0] = { promise, resolve, reject }
  stdin = process.openStdin()
  stdin.resume()
  stdin.setRawMode true
  stdin.on 'data', (buffer) ->
    if buffer[0] == 3 # Ctrl-C
      process.exit 1
    if nextKeypressDeferred[0]
      nextKeypressDeferred[0].resolve buffer[0]
      nextKeypressDeferred[0] = null

  db = new FlashcardsDb(new LocalStorage('./db'))
  noun = db.pickNounToReview()
  testTranslationToEnglish(noun)
    .then((response) -> db.saveNewResponse response)
else
  module.exports = {}
