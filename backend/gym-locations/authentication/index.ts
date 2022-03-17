import admin from 'firebase-admin';
import * as serviceAccount from './serviceAccount.json';

admin.initializeApp({
  credential: admin.credential.cert(JSON.stringify(serviceAccount)),
});

export default admin;
