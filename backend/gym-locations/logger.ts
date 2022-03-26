import winston from 'winston';

export const createLogger = () => winston.createLogger({
  transports: [
    new winston.transports.Console(),
    new winston.transports.File({filename: 'combined.log'}),
  ],
});
