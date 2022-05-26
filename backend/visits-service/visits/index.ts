
import express from 'express';
import authMiddleware from '../middlewares/authMiddleware';
import {authorize, getUserId} from '../authentication/auth';
import {create, get, getRecent} from '../visits/visits-service';
import * as bodyParser from 'body-parser';
import {CreateVisit} from './models/createVisit';

// eslint-disable-next-line new-cap
const router = express.Router();

const jsonParser = bodyParser.json();

router.all('/', authMiddleware);
router.all('/nearby', authMiddleware);

router.post('/', jsonParser, authorize, (req, res) => {
  const userId = getUserId(req);
  const newVisit: CreateVisit = {
    userId,
    lat: req.body.lat,
    lng: req.body.lng,
    createdDate: new Date(),
    gymId: req.body.gymId,
  };
  create(newVisit);

  res.send(newVisit);
});

router.get('/', jsonParser, authorize, async (req, res) => {
  const userId = getUserId(req);
  const locationsForUser = await get(userId);

  res.send(locationsForUser);
});

router.get('/recent', jsonParser, authorize, async (req, res) => {
  const userId = getUserId(req);
  const skip = Number.parseInt(req.query.skip as string, 10) ?? null;
  const top = Number.parseInt(req.query.take as string, 10) ?? null;
  const recentVisits = await getRecent(userId, {skip, top});

  res.send(recentVisits);
});

export default router;
