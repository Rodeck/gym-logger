import {Response, NextFunction} from 'express';
import {UserRequest} from '../gyms/models/userRequest';

export function authorize(req : UserRequest, res: Response, next: NextFunction) {
  if (req.user) {
    next();
  } else {
    res.status(200).send();
  }
}

export function getUserId(req: UserRequest): string | null {
  if (req.user) {
    return req.user.uid;
  }

  return null;
}
