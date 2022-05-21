import {Schema, model, connect, ConnectOptions} from 'mongoose';
import {Gym} from '../gyms/models/gym';

const configuration = {
  url: process.env.DB_URL,
  username: process.env.DB_USERNAME,
  password: process.env.DB_PASSWORD,
};

const clientOptions: ConnectOptions = {
  pass: configuration.password,
  user: configuration.username,
  dbName: 'gyms',
};

const gymSchema = new Schema<Gym>({
  name: {type: String, required: true},
  lat: {type: Number, required: true},
  lng: {type: Number, required: true},
  createdDate: {type: Date, required: true},
  userId: {type: String, required: true},
});

const GymModel = model<Gym>('Gym', gymSchema);

export const init = async () => await connect(configuration.url, clientOptions);

export const insertItem = async (item: Gym) => {
  const gym = new GymModel(item);

  await gym.save();
};

export const getItems = async (userId: string) : Promise<Gym[]> => {
  return await GymModel.find().where({
    userId,
  }).exec();
};
