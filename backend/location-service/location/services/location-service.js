
const { insertItem, getItems, getCollection } = require('./../../db')
const collectionName = 'locations';

const get = function(_userId){
    return getItems(collectionName).find({
        userId: _userId
    }).toArray();
}

const getRecent = function(_userId, amount){
    return getItems(collectionName).find({
        userId: _userId
    }).sort({
        date: 1
    }).limit(amount).toArray();
}

const create = function(location){
    insertItem(location, collectionName)
}

const getAll = function(){
    return getItems(collectionName)
}

module.exports = {
    get,
    getAll,
    create,
    getRecent
};