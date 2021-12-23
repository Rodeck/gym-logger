const dbConfig = require("./db.config.js");

const { MongoClient, ObjectId } = require('mongodb')

const dbName = 'store'

let db

const init = () =>
  MongoClient.connect(dbConfig.url, { useNewUrlParser: true }).then((client) => {
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
  return collection.find({}).toArray()
}

const getCollection = (collectionName) => {
  return  db.collection(collectionName)
  //return collection.updateOne({ _id: ObjectId(id) }, { $inc: { quantity } })
}

module.exports = { init, insertItem, getItems, getCollection }