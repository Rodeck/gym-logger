
const { insertItem, getItems, getCollection } = require('../../db')
var Distance = require('geo-distance');
const collectionName = 'gyms';
var jackrabbit = require('jackrabbit');
console.log(process.env.RABBIT_URL)
var rabbit = jackrabbit(process.env.RABBIT_URL)
var exchange = rabbit.default()

const get = function(_userId){
    return getCollection(collectionName).find({
        userId: _userId
    }).toArray();
}

const create = function(item){
    console.log("Creating new gym.");
    insertItem(item, collectionName);

    exchange.queue({ name: "gyms_create" });
    exchange.publish(item, { key: "gyms_create" });
}

const getAll = function(userId){
    return getCollection(collectionName).find({userId: userId}).toArray();
}

const getNearby = async function(userId, latitude, longitude){
    let allLocations = await getAll(userId);

    return allLocations.filter(l => isNearby({
        latitude: latitude,
        longitude: longitude,
    }, l));
}

const isNearby = function(currentLocation, gymLocation) {
    let distance = Distance.between({
        lat: currentLocation.latitude,
        lon: currentLocation.longitude,
    },
    {
        lat: gymLocation.latitude,
        lon: gymLocation.longitude,
    });

    console.log(distance, "Is closer than 10m: ", distance < Distance('10 m'));
    return distance < Distance('10 m');
}

module.exports = {
    get,
    getAll,
    create,
    getNearby
};