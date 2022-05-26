import {Document, ObjectId} from 'mongodb';

export interface Visit extends Document {
    lat: number;
    lng: number;
    createdDate: Date;
    userId: string;
    gymId: ObjectId;
}
