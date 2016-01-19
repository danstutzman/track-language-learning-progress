arrayDifference = (a1, a2) ->
  obj = {}
  for item in a2
    obj[item] = true
  difference = []
  for item in a1
    if !obj[item]
      difference.push item
  difference

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

class FlashcardsDb
  constructor: (@localStorage) ->

  _loadNouns: ->
    nounsJson = @localStorage.getItem 'nouns.json'
    if nounsJson is null
      throw new Error "Can't find nouns.json in localStorage"
    nounsTable = JSON.parse @localStorage.getItem 'nouns.json'

    nounKeys = nounsTable.shift()
    nouns = []
    for nounRow in nounsTable
      nounObject = {}
      for nounKey, i in nounKeys
        nounObject[nounKey] = nounRow[i]
      nouns.push nounObject
    nouns

  _loadResponses: ->
    JSON.parse(@localStorage.getItem('responses.json') or '[]')

  pickNounToReview: ->
    [nouns, responses] = [@_loadNouns(), @_loadResponses()]
    allNounIds = (noun.id for noun in nouns)
    nounIdsNeedingReview = arrayDifference(allNounIds,
      uniq(response.nounId for response in responses when response.correct))
    nounIdToReview = randomPick(nounIdsNeedingReview)
    nounsToReview = (noun for noun in nouns when noun.id == nounIdToReview)
    nounsToReview[0] # could be null if none

  saveNewResponse: (newResponse) ->
    responses = @_loadResponses()
    responses = responses.concat([newResponse])
    @localStorage.setItem 'responses.json', JSON.stringify(responses)

module.exports = FlashcardsDb
