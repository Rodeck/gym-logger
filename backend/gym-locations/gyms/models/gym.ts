import {Document, ObjectId} from 'mongodb';

export interface Gym extends Document {
    name: string;
    lat: number;
    lng: number;
    createdDate: Date;
    userId: string;
    _id: ObjectId;
}
