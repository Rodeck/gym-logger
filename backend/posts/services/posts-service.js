
const data = [
    {
        id: 1,
        name: "Post 1",
        content: "This is post number 1, how awesome."
    },
    {
        id: 2,
        name: "Post number two",
        content: "This is post number 2, even more epic."
    },
]

const get = function(_id){
    return getAll().find(account => account.id == _id);
}

const getAll = function(){
    return data;
}

module.exports = {
    get,
    getAll
};