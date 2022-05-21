export default class Distance {
  static between(first: {lat: number, lon: number}, second: {lat: number, lon: number}): number {
    return this.calcCrow(first, second);
  }

  static calcCrow(first: {lat: number, lon: number}, second: {lat: number, lon: number}) {
    const R = 6371; // km
    const dLat = Distance.toRad(second.lat-first.lat);
    const dLon = Distance.toRad(second.lon-first.lon);
    const lat1 = Distance.toRad(first.lat);
    const lat2 = Distance.toRad(second.lat);

    const a = Math.sin(dLat/2) * Math.sin(dLat/2) +
        Math.sin(dLon/2) * Math.sin(dLon/2) * Math.cos(lat1) * Math.cos(lat2);
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
    const d = R * c;
    return d;
  }

  static toRad(value: number) {
    return value * Math.PI / 180;
  }
}
