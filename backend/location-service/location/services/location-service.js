
const { insertItem, getItems, getCollection, buildId } = require('./../../db')
var Distance = require('geo-distance');
const collectionName = 'locations';
const collectionVisits = 'visits';
const collectionGyms = 'location-gyms';

const get = function(_userId){
    return getItems(collectionName).find({
        userId: _userId
    }).toArray();
}

const getRecent = function(_userId, amount){
    return getItems(collectionVisits).find({
        userId: _userId
    }).sort({
        date: -1
    }).limit(amount).toArray();
}

const deleteVisit = function(_userId, visitId) {
    let collection = getCollection(collectionVisits);
    let query = {
        userId: _userId,
        _id: buildId(visitId),
    };

    return collection.deleteOne(query);
}

const create = async function(location) {
    insertItem(location, collectionName);

    var nearbyGyms = await getNearby(location.userId, location.latitude, location.longitude);
    var hasOnGoingVisit = await hasOngoingVisit(location.userId);

    if (nearbyGyms.length > 0 && !hasOnGoingVisit) {
        // Add as visit
        var gym = nearbyGyms[0];

        console.log('Nearby gyms found: ', nearbyGyms);

        var visit = {
            date: new Date(),
            gymId: gym._id,
            gymName: gym.name,
            userId: location.userId,
            latitude: gym.latitude,
            longitude: gym.longitude,
        };

        console.log('Registering visit: ', visit);

        insertItem(visit, collectionVisits);
    }
}

const hasOngoingVisit = async function(userId) {
    var visits = await getItems(collectionVisits).find({
        userId: userId
    }).sort({
        date: -1
    }).limit(3).toArray();
    var now = new Date();

    var onGoingVisits = visits.filter(v => now - v.date < 100_000); 
    
    return onGoingVisits.length > 1;
}

const getAll = function(){
    return getItems(collectionName)
}

const getAllGyms = function(userId){
    return getItems(collectionGyms).find({
            userId: userId
    }).toArray();
}

const createNewGym = function(gym){
    var newGym = {
        userId: gym.userId,
        latitude: gym.latitude,
        longitude: gym.longitude,
        createdDate: gym.createdDate,
        name: gym.name,
    }
    insertItem(newGym, collectionGyms)
}

const getNearby = async function(userId, latitude, longitude){
    let allGyms = await getAllGyms(userId);

    return allGyms.filter(l => isNearby({
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
    getRecent,
    createNewGym,
    deleteVisit,
};