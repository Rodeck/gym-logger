

const { init } = require('./db')
var cors = require('cors')
const bodyParser = require("body-parser")
const swaggerJsdoc = require("swagger-jsdoc")
const swaggerUi = require("swagger-ui-express")

const express = require('express')
const app = express()

const environment = process.env.environment ?? 'local';
const port = environment == 'local' ? 3000 : 80

const admin = require('./authentication/index');
var postRoutes = require('./posts/index')
var locationRoutes = require('./location/index')

app.use(cors())

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

app.use('/post', postRoutes)
app.use('/location', locationRoutes)

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
          url: "http://localhost:3000/",
        },
      ],
    },
    apis: ["./posts/index.js", "index.js", "./location/index.js"],
  };
  
const specs = swaggerJsdoc(options);
app.use(
    "/api-docs",
    swaggerUi.serve,
    swaggerUi.setup(specs)
)

app.use(express.json())

app.get('/', (req, res) => {
  res.send('Hello World from location service!')
})

init().then(() => {
    console.log('starting server on port', port)
    app.listen(port)
})