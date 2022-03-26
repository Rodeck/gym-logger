
import express from 'express';
import authMiddleware from '../middlewares/authMiddleware';
import {authorize, getUserId} from '../authentication/auth';
import {create, getAll, getNearby} from './services/gyms-service';
import * as bodyParser from 'body-parser';

// eslint-disable-next-line new-cap
const router = express.Router();

const jsonParser = bodyParser.json();

router.all('/', authMiddleware);

router.post('/', jsonParser, authorize, (req, res) => {
  const userId = getUserId(req);
  const newGym = {
    userId,
    lat: req.body.latitude,
    lng: req.body.longitude,
    createdDate: new Date(),
    name: req.body.name,
  };
  create(newGym);

  res.send(newGym);
});

router.get('/', jsonParser, authorize, async (req, res) => {
  const userId = getUserId(req);
  const locationsForUser = await getAll(userId);

  res.send(locationsForUser);
});

router.get('/nearby', jsonParser, authorize,
    async (req, res) => {
      const latitude = Number.parseFloat(req.query.latitude as string);
      const longitude = Number.parseFloat(req.query.longitude as string);
      const userId = getUserId(req);

      if (latitude == null || longitude == null) {
        res.statusCode = 400;
        res.send();
      }

      const nearbyLocations = await getNearby(userId, latitude, longitude);
      res.send(nearbyLocations);
    });

export default router;
