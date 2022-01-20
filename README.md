# gym-logger

## Goal
The goal is to create application which helps to log visits to the gym by automaticaly saving gym visits to the yser profile.

## Backend
Backend is built using express.js library.

### Setup:

1. Create serviceAccount.json file (backend/authentication/serviceAccount.json) with template:
```json
{
    "type": "service_account",
    "project_id": "",
    "private_key_id": "",
    "private_key": "",
    "client_email": "",
    "client_id": "",
    "auth_uri": "",
    "token_uri": "",
    "auth_provider_x509_cert_url": "",
    "client_x509_cert_url": ""
}
```
2. Run mongodb via docker-compose `docker-compose -f db-compose.yml up`
3. Run the app with commands:

`npm install`

`npm start`

## Frontend

### Mobile
Mobile application is written in flutter.

#### Setup

1. Setup flutter
2. Setup firebase settings via FlutterFire CLI
3. Setup google-services.json, donwload it from firebase console and place in frontend/mobile/android/app/google-service.json
4. Launch emulator (shift + P and type lanuch in VS code or launch manually)
5. Run the app with `flutter run`
