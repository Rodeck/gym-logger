var express = require('express')
var postsService = require("./services/posts-service");
var router = express.Router()

// middleware that is specific to this router
router.use(function timeLog (req, res, next) {
  console.log('Time: ', Date.now())
  next()
})
// define the home page route
router.get('/', function (req, res) {
  res.send(postsService.getAll())
})
// define the about route
router.get('/top', function (req, res) {
  res.send(postsService.get(1))
})

module.exports = router