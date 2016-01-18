fs             = require 'fs'
{LocalStorage} = require 'node-localstorage'
readline       = require 'readline'

uniq = (list) ->
  obj = {}
  for item in list
    obj[item] = true
  keys = []
  for key of obj
    keys.push key
  keys

randomPick = (list) ->
  list[Math.floor(Math.random() * list.length)]

arrayDifference = (a1, a2) ->
  obj = {}
  for item in a2
    obj[item] = true
  difference = []
  for item in a1
    if !obj[item]
      difference.push item
  difference

localStorage = new LocalStorage './db'
rl = readline.createInterface input: process.stdin, output: process.stdout

nounsJson = localStorage.getItem 'nouns.json'
if nounsJson is null
  throw new Error "Can't find nouns.json in localStorage"
nounsTable = JSON.parse localStorage.getItem 'nouns.json'

nounKeys = nounsTable.shift()
nouns = []
for nounRow in nounsTable
  nounObject = {}
  for nounKey, i in nounKeys
    nounObject[nounKey] = nounRow[i]
  nouns.push nounObject

oldResponses = JSON.parse(localStorage.getItem('responses.json') or '[]')
allNounIds = (noun.id for noun in nouns)
nounIdsNeedingReview = arrayDifference(allNounIds,
  uniq(response.nounId for response in oldResponses when response.correct))
nounIdToReview = randomPick(nounIdsNeedingReview)
nounsToReview = (noun for noun in nouns when noun.id == nounIdToReview)
if nounsToReview.length == 0
  console.error 'No nouns to review'
  process.exit 0
noun = nounsToReview[0]

questionAt = Date.now()
await rl.question "Translate to English: #{noun.spanish}\n", defer answer
# round responseDelay to nearest tenth of second
responseDelay = Math.floor((Date.now() - questionAt) / 100) * 100 / 1000
correct = (answer is noun.english)
if correct
  console.log 'correct!'
else
  console.log "incorrect - expected #{noun.english}"
response =
  nounId: noun.id
  correct: correct
  questionAt: Math.floor(questionAt / 1000)
  responseDelay: responseDelay
localStorage.setItem 'responses.json', JSON.stringify(oldResponses.concat([response]))
rl.close() # otherwise program will keep waiting on stdin
