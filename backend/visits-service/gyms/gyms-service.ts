/* eslint-disable new-cap */
/* eslint-disable no-console */
import {Gym} from './models/gym';
import {insertGym, getGymWithName} from './../db';
import {createLogger} from './../logger';

const logger = createLogger();

export const create = async (item: Gym): Promise<void> => {
  const gym = await getGymWithName(item.gymName);

  if (gym != null) {
    logger.error(`gym with name ${item.gymName} already exists`);
    return Promise.reject(new Error('Gym not found'));
  }

  logger.info(`Creating new gym: ${JSON.stringify(item)}`);
  insertGym(item);
};
