var express = require('express')
var service = require("./services/location-service");
var router = express.Router()
var authorization = require('./../authentication/auth')

const bodyParser = require("body-parser")
const jsonParser = bodyParser.json();

// middleware that is specific to this router
router.use(function timeLog (req, res, next) {
  next()
})

/**
 * @swagger
 * /location:
 *   post:
 *     summary: Create a JSONPlaceholder user.
 *     description: Create new location for given user
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *                     userId:
 *                       type: string
 *                       description: Id of the user.
 *                       example: "ae3b7799-84f0-4b0b-9c97-9769371ce57c"
 *                     latitude:
 *                       type: number
 *                       description: Latitude part of the location.
 *                       example: 53.162378628843285
 *                     longitude:
 *                       type: number
 *                       description: Longitude part of the location.
 *                       example: 18.168187942317314
 *     responses:
 *       201:
 *         description: Created
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 data:
 *                   type: object
 *                   properties:
 *                     userId:
 *                       type: string
 *                       description: Id of the user.
 *                       example: "ae3b7799-84f0-4b0b-9c97-9769371ce57c"
 *                     latitude:
 *                       type: number
 *                       description: Latitude part of the location.
 *                       example: 53.162378628843285
 *                     longitude:
 *                       type: number
 *                       description: Longitude part of the location.
 *                       example: 18.168187942317314
*/
router.post('/', jsonParser, authorization.authorize, function (req, res) {
    let userId = authorization.getUserId(req);
    let location = {
      userId: userId,
      latitude: req.body.latitude,
      longitude: req.body.longitude,
    }
    res.send(service.create(location))
  })

/**
 * @swagger
 * /location/{userId}:
 *      get:
 *          description: Get all locations for given user
 *          parameters:
 *            - in: path
 *              name: userId
 *              schema:
 *                type: string
 *                required: true
 *                description: Id of the user
 *          responses:
 *              "200":
 *                  description: List of the locations for given user
 *                  content:
 *                      application/json:
 *                          schema:
 *                              type: object
 *                              properties:
 *                              data:
 *                                  type: object
 *                                  properties:
 *                                    userId:
 *                                      type: string
 *                                      description: Id of the user.
 *                                      example: "ae3b7799-84f0-4b0b-9c97-9769371ce57c"
 *                                    latitude:
 *                                      type: number
 *                                      description: Latitude part of the location.
 *                                      example: 53.162378628843285
 *                                    longitude:
 *                                      type: number
 *                                      description: Longitude part of the location.
 *                                      example: 18.168187942317314
 */
router.get('/:userId', async (req, res) => {
  let userId = req.params["userId"];
  let locations = await service.get(userId);
  res.send(locations)
})

router.get('/', function (req, res) {
  res.send(service.getAll())
})

module.exports = router