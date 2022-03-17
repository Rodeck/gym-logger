import {DecodedIdToken} from 'firebase-admin/lib/auth/token-verifier';

export interface User extends DecodedIdToken {
}
