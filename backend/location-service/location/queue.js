
var jackrabbit = require('jackrabbit');
var rabbit = jackrabbit(process.env.RABBIT_URL);
var service = require("./services/location-service")

function initializeListeners()
{
    var exchange = rabbit.default();
    var queue = exchange.queue({ name: "gyms_create" })
    queue.consume(onGymCreated, { noAck: true })
}

function onGymCreated(newGymData) {
  console.log('Creating new gym: ', newGymData);
  service.createNewGym(newGymData)
}

module.exports = {
    initializeListeners,
};