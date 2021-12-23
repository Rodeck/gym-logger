const { init } = require('./db')

const express = require('express')
const app = express()
const port = 3000
var posts = require('./posts/index')

app.use('/posts', posts)

app.get('/', (req, res) => {
  res.send('Hello World!')
})

init().then(() => {
    console.log('starting server on port 3000')
    app.listen(port)
})