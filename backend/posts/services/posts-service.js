
const { insertItem, getItems, getCollection } = require('./../../db')
const postsCollection = 'posts';

const get = function(_id){
    return getItems(postsCollection).find(p => p._id == _id)
}

const create = function(post){
    insertItem(post, postsCollection)
}

const getAll = function(){
    return getItems(postsCollection)
}

module.exports = {
    get,
    getAll
};