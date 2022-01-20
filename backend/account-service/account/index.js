
var express = require('express')
var router = express.Router()
var authorization = require('./../authentication/auth')
var accountService = require('./services/account-service')

const bodyParser = require("body-parser")
const jsonParser = bodyParser.json();

/**
 * @swagger
 * /account:
 *      post:
 *          description: Get health status
 *          requestBody:
 *              required: true
 *              content:
 *                application/json:
 *                  schema:
 *                    type: object
 *                    properties:
 *                         userId:
 *                           type: string
 *                           description: Id of the user.
 *                           example: abc123
 *                         email:
 *                           type: string
 *                           description: Email of the user.
 *                           example: user@gmail.com
 *          responses:
 *              "200":
 *                   description: List of the locations for given user
 *                   content:
 *                       application/json:
 *                           schema:
 *                               type: object
 *                               properties:
 *                               data:
 *                                   type: object
 *                                   properties:
 *                                     userId:
 *                                         type: string
 *                                         description: Id of the user.
 *                                         example: abc123
 *                                     email:
 *                                         type: string
 *                                         description: Email of the user.
 *                                         example: user@gmail.com
 *                                     createdDate:
 *                                         type: string
 *                                         description: Creation date.
 *                                         example: 2022-01-10
 *                                     isLocked:
 *                                         type: boolean
 *                                         description: Information whether account is locked.
 *                                         example: false
 */
router.post('/', jsonParser, authorization.authorize, function (req, res) {
    let userId = authorization.getUserId(req);
    var newAccount = {
        userId: userId,
        email: req.body.email,
        createdDate: new Date(),
        isLocked: false,
    }
    accountService.create(newAccount);

    res.send(newAccount);
  })
  
module.exports = router