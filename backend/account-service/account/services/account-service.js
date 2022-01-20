
const { insertItem, getItems, getCollection } = require('./../../db')
const collectionName = 'account';

const get = function(_userId){
    return getItems(collectionName).find({
        userId: _userId
    }).toArray();
}

const create = function(item){
    insertItem(item, collectionName)
}

const getAll = function(){
    return getItems(collectionName)
}

module.exports = {
    get,
    getAll,
    create
};