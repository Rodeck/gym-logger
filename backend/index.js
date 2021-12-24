const { init } = require('./db')
const bodyParser = require("body-parser")
const swaggerJsdoc = require("swagger-jsdoc")
const swaggerUi = require("swagger-ui-express")

const express = require('express')
const app = express()
const port = 3000
var posts = require('./posts/index')

app.use('/posts', posts)
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
    apis: ["./posts/index.js", "index.js"],
  };
  
const specs = swaggerJsdoc(options);
app.use(
    "/api-docs",
    swaggerUi.serve,
    swaggerUi.setup(specs)
)

app.use(express.json())

app.get('/', (req, res) => {
  res.send('Hello World!')
})

init().then(() => {
    console.log('starting server on port 3000')
    app.listen(port)
})