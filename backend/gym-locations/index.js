
require('dotenv').config()
const { init } = require('./db')
var cors = require('cors')

const express = require('express')
const app = express()
const admin = require('./authentication/index');
var routes = require('./gyms/index')
var listeners = require('./gyms/queue');

const environment = process.env.environment ?? 'local';
const port = environment == 'local' ? 3002 : 80

app.use(cors())
app.set('port', port);

app.use(async function (req, res, next) {

  let token = req.headers.authorization;
  if (token) {
    try {
      const decodeValue = await admin.auth().verifyIdToken(token);
      if (decodeValue) {
        //const uid = decodedToken.uid;
        req.user = decodeValue;
      }
    } catch {
    }
  }

  next()
})

app.use('/', routes)

app.use(express.json())

app.get('/health', (req, res) => {
  res.send('Hello World from gym locations service!')
})

init().then(() => {
    console.log('starting server on port', port)

    listeners.initializeListeners();

    app.listen(port)
})