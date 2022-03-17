

const { init } = require('./db')
var cors = require('cors')
const bodyParser = require("body-parser")
const swaggerJsdoc = require("swagger-jsdoc")
const swaggerUi = require("swagger-ui-express")

const express = require('express')
const app = express()
const admin = require('./authentication/index');
var postRoutes = require('./account/index')

const environment = process.env.environment ?? 'local';
const port = environment == 'local' ? 3000 : 80

app.use(cors())
app.set('port', port);

app.use(async function (req, res, next) {

  let token = req.headers.authorization;
  if (token) {
    const decodeValue = await admin.auth().verifyIdToken(token);
    if (decodeValue) {
      //const uid = decodedToken.uid;
      req.user = decodeValue;
    }
  }

  next()
})

app.use('/', postRoutes)

const options = {
    definition: {
      openapi: "3.0.0",
      info: {
        title: "",
        version: "0.1.0",
        description:
          "",
        license: {
        },
        contact: {
        },
      },
      servers: [
        {
          url: "http://localhost:3001/",
        },
      ],
    },
    apis: ["index.js", "./account/index.js"],
  };
  
const specs = swaggerJsdoc(options);
app.use(
    "/api-docs",
    swaggerUi.serve,
    swaggerUi.setup(specs)
)

app.use(express.json())

app.get('/health', (req, res) => {
  res.send('Hello World from account service!')
})

init().then(() => {
    console.log('starting server on port', port)
    app.listen(port)
})