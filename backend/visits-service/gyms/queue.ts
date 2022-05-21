import jackrabbit from 'jackrabbit';
import {Gym} from './models/gym';
import {create} from './gyms-service';

const rabbit = jackrabbit(process.env.RABBIT_URL);

export default function initializeListeners() {
  const exchange = rabbit.default();
  const queue = exchange.queue({name: 'gyms_create'});
  queue.consume(onGymCreated, {noAck: true});
}

function onGymCreated(newGym: Gym) {
  create(newGym);
}
