import {UserRequest} from '../gyms/models/userRequest';
import {Response, NextFunction} from 'express';
import {createLogger} from '../logger';

const logger = createLogger();

export default async function(error: Error, req : UserRequest, res: Response, next: NextFunction)
: Promise<void> {
  const message = error.message || 'Something went wrong';
  logger.error(message, error);
  res
      .status(500)
      .send({
        message,
      });
}
