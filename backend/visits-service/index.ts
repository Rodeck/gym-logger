import 'dotenv/config';
import {init} from './db';
import cors from 'cors';
import express from 'express';
import winston from 'winston';
import errorMiddleware from './middlewares/errorMiddleware';
import router from './visits/index';
import initializeListeners from './gyms/queue';

const logger = winston.createLogger({
  level: 'info',
  format: winston.format.json(),
  defaultMeta: {service: 'visits'},
  transports: [
    //
    // - Write all logs with importance level of `error` or less to `error.log`
    // - Write all logs with importance level of `info` or less to `combined.log`
    //
    new winston.transports.File({filename: 'error.log', level: 'error'}),
    new winston.transports.File({filename: 'combined.log'}),
  ],
});

if (process.env.NODE_ENV !== 'production') {
  logger.add(new winston.transports.Console({
    format: winston.format.simple(),
  }));
}

const app = express();

const environment = process.env.environment ?? 'local';
const port = environment === 'local' ? 3001 : 80;

app.use(cors());
app.set('port', port);
app.use('/', router);

app.use(express.json());

app.get('/health', (req, res) => {
  res.send('Hello World from visits service!');
});

app.use(errorMiddleware);

init().then(() => {
  logger.info(`starting server on port ${port}`);

  initializeListeners();
  app.listen(port);
});
