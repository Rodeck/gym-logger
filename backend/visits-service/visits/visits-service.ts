/* eslint-disable new-cap */
/* eslint-disable no-console */
import {Visit} from './models/visit';
import {insertVisit, getGym, getVisits, getRecentVisits} from './../db';
import {createLogger} from './../logger';
import {CreateVisit} from './models/createVisit';
import {ObjectId} from 'mongodb';

const logger = createLogger();

export const get = async (_userId: string): Promise<Visit[]> => await getVisits(_userId);
export const getRecent = async (_userId: string,
    paging: { top: number | null, skip: number | null } | null)
: Promise<Visit[]> => await getRecentVisits(_userId, paging);

export const create = async (item: CreateVisit): Promise<void> => {
  const gym = await getGym(item.gymId);

  if (gym == null) {
    logger.error(`gym with id ${item.gymId} not found`);
    return Promise.reject(new Error('Gym not found'));
  }

  const visit : Visit = {
    lat: item.lat,
    lng: item.lng,
    userId: item.userId,
    createdDate: item.createdDate,
    gymId: new ObjectId(item.gymId),
  };
  logger.info(`Creating new visit: ${JSON.stringify(visit)}`);
  insertVisit(visit);
};
