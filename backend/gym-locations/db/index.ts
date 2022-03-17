import {Collection, Db, MongoClient,
  MongoClientOptions, ObjectId, Document, OptionalId} from 'mongodb';
import config from './../config';

const configuration = {
  url: config.DB_URL,
  username: config.DB_USERNAME,
  password: config.DB_PASSWORD,
};

const clientOptions: MongoClientOptions = {
  auth: {
    username: configuration.username,
    password: configuration.password,
  },
};

const dbName = 'store';

let db: Db;

export const init = () =>
  MongoClient.connect(configuration.url, clientOptions).then((client) => {
    db = client.db(dbName);
  });

export const insertItem = (
    item: OptionalId<Document>,
    collectionName: string) => {
  const collection = db.collection(collectionName);
  const id = new ObjectId();
  item._id = id;
  return collection.insertOne(item);
};

export const getItems = (collectionName: string) : Collection<Document> => {
  const collection = db.collection(collectionName);
  return collection;
};

export const getCollection = (collectionName: string)
    : Collection<Document> => {
  return db.collection(collectionName);
};
