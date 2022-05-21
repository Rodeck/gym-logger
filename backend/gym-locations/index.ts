
import 'dotenv/config';
import {init} from './db';
import cors from 'cors';
import express from 'express';
import router from './gyms/index';
import winston from 'winston';
import errorMiddleware from './middlewares/errorMiddleware';

const logger = winston.createLogger({
  level: 'info',
  format: winston.format.json(),
  defaultMeta: {service: 'gyms'},
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
const port = environment === 'local' ? 3002 : 80;

app.use(cors());
app.set('port', port);
app.use('/', router);

app.use(express.json());

app.get('/health', (req, res) => {
  res.send('Hello World from gym locations service!');
});

app.use(errorMiddleware);

init().then(() => {
  logger.info(`starting server on port ${port}`);

  app.listen(port);
});
