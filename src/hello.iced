fs             = require 'fs'
{LocalStorage} = require 'node-localstorage'
readline       = require 'readline'

localStorage = new LocalStorage './db'
rl = readline.createInterface input: process.stdin, output: process.stdout

nouns_json = localStorage.getItem 'nouns.json'
if nouns_json is null
  throw new Error "Can't find nouns.json in localStorage"
nouns_table = JSON.parse localStorage.getItem 'nouns.json'

noun_keys = nouns_table.shift()
nouns = []
for noun_row in nouns_table
  noun_object = {}
  for noun_key, i in noun_keys
    noun_object[noun_key] = noun_row[i]
  nouns.push noun_object

noun_num = Math.floor(Math.random() * nouns.length)
noun = nouns[noun_num]
await rl.question "Translate to English: #{noun.spanish}\n", defer answer
correct = (answer is noun.english)
if correct
  console.log 'correct!'
else
  console.log "incorrect - expected #{noun.english}"
localStorage.setItem 'results.json', JSON.stringify(correct)
rl.close() # otherwise program will keep waiting on stdin
