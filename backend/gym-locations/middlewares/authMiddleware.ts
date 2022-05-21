import {UserRequest} from '../gyms/models/userRequest';
import admin from './../authentication/';
import {Response, NextFunction} from 'express';
import {createLogger} from '../logger';

const logger = createLogger();

export default async function(req : UserRequest, res: Response, next: NextFunction): Promise<void> {
  const token = req.headers.authorization;
  if (token) {
    try {
      const decodeValue = await admin.auth().verifyIdToken(token);
      if (decodeValue) {
        req.user = decodeValue;
      }
    } catch (e) {
      logger.warn('Unauthorized access.', e);
    }
  }
  next();
}
