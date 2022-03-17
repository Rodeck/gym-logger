import {User} from './user';
import {Request} from 'express';

export interface UserRequest extends Request {
    user?: User
}
