import {Gym} from '../gyms/models/gym';
import {Schema, model, connect, ConnectOptions} from 'mongoose';
import {Visit} from '../visits/models/visit';
import {ObjectId} from 'mongodb';

const configuration = {
  url: process.env.DB_URL,
  username: process.env.DB_USERNAME,
  password: process.env.DB_PASSWORD,
};

const clientOptions: ConnectOptions = {
  pass: configuration.password,
  user: configuration.username,
  dbName: 'visits',
};

const gymSchema = new Schema<Gym>({
  name: {type: String, required: true},
  lat: {type: Number, required: true},
  lng: {type: Number, required: true},
  createdDate: {type: Date, required: true},
  userId: {type: String, required: true},
});

const visitSchema = new Schema<Visit>({
  lat: {type: Number, required: true},
  lng: {type: Number, required: true},
  createdDate: {type: Date, required: true},
  userId: {type: String, required: true},
  gymId: {type: ObjectId, required: true},
});

const GymModel = model<Gym>('Gym', gymSchema);
const VisitModel = model<Visit>('Visit', visitSchema);

export const init = async () => await connect(configuration.url, clientOptions);

export const insertGym = async (item: Gym) => {
  const itemModel = new GymModel(item);

  await itemModel.save();
};

export const insertVisit = async (item: Visit) => {
  const itemModel = new VisitModel(item);

  await itemModel.save();
};

export const getGyms = async (userId: string) : Promise<Gym[]> => {
  return await GymModel.find().where({
    userId,
  }).exec();
};

export const getVisits = async (userId: string) : Promise<Visit[]> => {
  return await VisitModel.find().where({
    userId,
  }).exec();
};

export const getRecentVisits = async (userId: string,
    paging: { top: number | null, skip: number | null } | null)
: Promise<Visit[]> => {
  return await VisitModel.find().where({
    userId,
  }).sort({
    date: -1,
  }).skip(paging?.skip ?? 0)
      .limit(paging?.top ?? 10)
      .exec();
};

export const getGym = async (gymId: string) : Promise<Gym> => {
  return await GymModel.findOne().where({
    _id: gymId,
  }).exec();
};

export const getGymWithName = async (name: string) : Promise<Gym> => {
  return await GymModel.findOne().where({
    name,
  }).exec();
};
