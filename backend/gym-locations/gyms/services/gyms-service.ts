/* eslint-disable new-cap */
/* eslint-disable no-console */
import {Gym} from '../models/gym';
import jackrabbit from 'jackrabbit';
import {insertItem, getItems} from '../../db';
import {createLogger} from '../../logger';
import Distance from '../../util/distance';

// tslint:disable-next-line: no-console
console.log(process.env.RABBIT_URL);

const rabbit = jackrabbit(process.env.RABBIT_URL);
const exchange = rabbit.default();
const logger = createLogger();

export const get = async (_userId: string): Promise<Gym[]> => await getItems(_userId);

export const create = (item: Gym): void => {
  insertItem(item);

  exchange.queue({name: 'gyms_create'});
  exchange.publish(item, {key: 'gyms_create'});
};

export const getAll = async (userId: string): Promise<Gym[]> => await getItems(userId);

export const getNearby = async (userId: string, latitude: number,
    longitude: number): Promise<Gym[]> => {
  const allLocations = await getAll(userId);

  return allLocations.filter((l) => isNearby({
    lat: latitude,
    lng: longitude,
  }, l));
};

export const isNearby = (currentLocation: { lat: number; lng: number; },
    gymLocation: Gym): boolean => {
  const distance = Distance.between({
    lat: currentLocation.lat,
    lon: currentLocation.lng,
  },
  {
    lat: gymLocation.lat,
    lon: gymLocation.lng,
  });

  logger.log({
    level: 'info',
    message: `${distance} is closer than 10m: ${distance < 0.001}`,
  });

  return distance < 0.001;
};
