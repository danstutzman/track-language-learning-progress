fs             = require 'fs'
{LocalStorage} = require 'node-localstorage'
readline       = require 'readline'
Q              = require 'q'
FlashcardsDb   = require './FlashcardsDb'

isEnglishAnswerAcceptable = (userAnswer, noun) ->
  noun.english_options.indexOf(userAnswer) != -1

askQuestion = (noun, rl) ->
  deferred = Q.defer()
  questionAt = Date.now()
  rl.question "Translate to English: #{noun.spanish}\n", (answer) ->
    # round responseDelay to nearest tenth of second
    responseDelay = Math.floor((Date.now() - questionAt) / 100) * 100 / 1000
    correct = isEnglishAnswerAcceptable(answer, noun)
    if correct
      console.log 'correct!'
    else
      expected = ("\"#{english}\"" for english in noun.english_options).join(' or ')
      console.log "incorrect - expected #{expected}"
    response =
      nounId: noun.id
      correct: correct
      questionAt: Math.floor(questionAt / 1000)
      responseDelay: responseDelay
    rl.close() # otherwise program will keep waiting on stdin
    deferred.resolve response
  deferred.promise

if module == require.main
  rl = readline.createInterface input: process.stdin, output: process.stdout
  db = new FlashcardsDb(new LocalStorage('./db'))
  noun = db.pickNounToReview()
  askQuestion(noun, rl).then (response) ->
    db.saveNewResponse response
else
  module.exports = {
    isEnglishAnswerAcceptable
  }
