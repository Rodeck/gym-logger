const express = require('express')
const app = express()
const port = 3000
var posts = require('./posts/index')

app.use('/posts', posts)

app.get('/', (req, res) => {
  res.send('Hello World!')
})

app.listen(port, () => {
  console.log(`Example app listening at http://localhost:${port}`)
})