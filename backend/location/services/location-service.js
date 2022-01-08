
const { insertItem, getItems, getCollection } = require('./../../db')
const collectionName = 'locations';

const get = function(_userId){
    return getItems(collectionName).find({
        userId: _userId
    }).toArray();
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
    create
};