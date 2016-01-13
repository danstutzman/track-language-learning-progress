{LocalStorage} = require('node-localstorage')
localStorage = new LocalStorage('./db')

localStorage.setItem 'myFirstKey', 'myFirstValue'
console.log localStorage.getItem 'myFirstKey'
