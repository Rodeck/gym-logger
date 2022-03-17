
import dotenv from 'dotenv';
import { init } from './db';
import cors from 'cors';
import express from 'express';
import { User } from './gyms/models/user';
import router from './gyms/index';

dotenv.config();

const app = express()
const listeners = require('./gyms/queue');

const environment = process.env.environment ?? 'local';
const port = environment == 'local' ? 3002 : 80

app.use(cors())
app.set('port', port);
app.use('/', router)

app.use(express.json())

app.get('/health', (req, res) => {
  res.send('Hello World from gym locations service!')
})

init().then(() => {
    console.log('starting server on port', port)

    listeners.initializeListeners();

    app.listen(port)
})