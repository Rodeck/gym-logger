
var express = require('express')
var router = express.Router()
var authorization = require('../authentication/auth')
var service = require('./services/gyms-service')
const bodyParser = require("body-parser")
const jsonParser = bodyParser.json();

router.post('/', jsonParser, authorization.authorize, function (req, res) {
  let userId = authorization.getUserId(req);
  var newGymLocation = {
      userId: userId,
      latitude: req.body.latitude,
      longitude: req.body.longitude,
      createdDate: new Date(),
      name: req.body.name,
  }
  service.create(newGymLocation);

  res.send(newGymLocation);
})

router.get('/', jsonParser, authorization.authorize, async function (req, res) {
  let userId = authorization.getUserId(req);
  let locationsForUser = await service.getAll(userId);

  res.send(locationsForUser);
})

router.get('/nearby', jsonParser, authorization.authorize, async function (req, res) {
  let latitude = req.query.latitude;
  let longitude = req.query.longitude;
  let userId = authorization.getUserId(req);

  if (latitude == null || longitude == null) {
    res.statusCode = 400;
    res.send();
  }

  let nearbyLocations = await service.getNearby(userId, latitude, longitude);
  res.send(nearbyLocations);
})
  
module.exports = router