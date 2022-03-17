import {Gym} from '../models/gym';

const {insertItem, getCollection} = require('../../db');
const Distance = require('geo-distance');
const collectionName = 'gyms';
const jackrabbit = require('jackrabbit');
const rabbit = jackrabbit(process.env.RABBIT_URL);
const exchange = rabbit.default();

export const get = function(_userId: string) : Gym[] {
  return getCollection(collectionName).find({
    userId: _userId,
  }).toArray();
};

export const create = function(item: Gym) : void {
  console.log('Creating new gym.');
  insertItem(item, collectionName);

  exchange.queue({name: 'gyms_create'});
  exchange.publish(item, {key: 'gyms_create'});
};

export const getAll = function(userId: string) : Gym[] {
  return getCollection(collectionName).find({userId}).toArray();
};

export const getNearby = async function(userId: string, latitude: number,
    longitude: number): Promise<Gym[]> {
  const allLocations = await getAll(userId);

  return allLocations.filter((l) => isNearby({
    lat: latitude,
    lng: longitude,
  }, l));
};

export const isNearby = function(currentLocation: { lat: number; lng: number },
    gymLocation: Gym) : boolean {
  const distance = Distance.between({
    lat: currentLocation.lat,
    lon: currentLocation.lng,
  },
  {
    lat: gymLocation.lat,
    lon: gymLocation.lng,
  });

  // eslint-disable-next-line new-cap
  console.log(distance, 'Is closer than 10m: ', distance < Distance('10 m'));
  // eslint-disable-next-line new-cap
  return distance < Distance('10 m');
};
