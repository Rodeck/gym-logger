const { MongoClient, ObjectId } = require('mongodb')

const env = process.env.environment ?? 'local';
const dbConfig = require(env == 'local' ? './db.config' : './db.config.compose')

const dbName = 'store'

let db

const init = () =>
  MongoClient.connect(dbConfig.url, { useNewUrlParser: true, auth: {
    username: dbConfig.username,
    password: dbConfig.password
  } }).then((client) => {
    db = client.db(dbName)
  })

const insertItem = (item, collectionName) => {
  const collection = db.collection(collectionName)
  let id = new ObjectId();
  item._id = id;
  return collection.insertOne(item)
}

const getItems = (collectionName) => {
  const collection = db.collection(collectionName)
  return collection
}

const getCollection = (collectionName) => {
  return  db.collection(collectionName)
}

module.exports = { init, insertItem, getItems, getCollection }