var express = require('express')
var service = require("./services/location-service")
var router = express.Router()
var authorization = require('./../authentication/auth')

const bodyParser = require("body-parser")
const jsonParser = bodyParser.json();

// middleware that is specific to this router
router.use(function timeLog (req, res, next) {
  next()
})

router.post('/', jsonParser, authorization.authorize, function (req, res) {
    let userId = authorization.getUserId(req);
    onLocationReceived(userId, req, res);
})

router.post('/test', jsonParser, function (req, res) {
    onLocationReceived(req.body.userId, req, res);
})

function onLocationReceived(userId, req, res) {
  let location = {
    userId: userId,
    latitude: req.body.latitude,
    longitude: req.body.longitude,
    date: req.body.date,
  }

  res.send(service.create(location))
}

router.get('/last', authorization.authorize, async (req, res) => {
  let userId = authorization.getUserId(req);
  let take = req.query.take;
  let locations = await service.getRecent(userId, parseInt(take));

  res.send(locations.map(l => {
    if (l.date === '' || l.date == null) {
      l.date = new Date(2022,1,1,1,1,0);
    }

    return l;
  }))
})

router.delete('/:visitId', authorization.authorize, async (req, res) => {
  let userId = authorization.getUserId(req);
  let visitId = req.params.visitId;
  let result = await service.deleteVisit(userId, visitId);

  if (result.deletedCount == 1) {
    res.send('Ok');
    return;
  }

  res.statusCode = 402;
  res.send('Error');
})

router.get('/health', (req, res) => {
  res.send('Hello World from locations service!')
})

router.get('/', function (req, res) {
  res.send(service.getAll())
})

module.exports = router