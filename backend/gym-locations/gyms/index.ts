
import express from 'express';
import authMiddleware from '../middlewares/authMiddleware';
import {authorize, getUserId} from '../authentication/auth';
import {create, getAll, getNearby} from './services/gyms-service';
import * as bodyParser from 'body-parser';
import {Gym} from './models/gym';

// eslint-disable-next-line new-cap
const router = express.Router();

const jsonParser = bodyParser.json();

router.all('/', authMiddleware);
router.all('/nearby', authMiddleware);

router.post('/', jsonParser, authorize, (req, res) => {
  const userId = getUserId(req);
  const newGym = {
    userId,
    lat: req.body.lat,
    lng: req.body.lng,
    createdDate: new Date(),
    name: req.body.name,
  };

  if (!validateGym(newGym)) {
    res.status(400).send('Invalid gym');
    return;
  }

  create(newGym);

  res.send(newGym);
});

function validateGym(gym: Gym) : boolean {
  return gym.lat != null && gym.lng != null && gym.name != null;
}

router.get('/', jsonParser, authorize, async (req, res) => {
  const userId = getUserId(req);
  const locationsForUser = await getAll(userId);

  res.send(locationsForUser);
});

router.get('/nearby', jsonParser, authorize,
    async (req, res, next) => {
      try {
        const latitude = (+(req.query.lat as string).replace(',', '.'));
        const longitude = (+(req.query.lng as string).replace(',', '.'));
        const userId = getUserId(req);

        if (latitude == null || longitude == null) {
          res.statusCode = 400;
          res.send();
        }

        const nearbyLocations = await getNearby(userId, latitude, longitude);
        res.send(nearbyLocations);
      } catch (error) {
        next(error);
      }
    });

export default router;
