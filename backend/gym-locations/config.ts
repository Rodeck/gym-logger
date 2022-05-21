// import path from 'path';
// import dotenv from 'dotenv';

// dotenv.config({path: path.resolve(__dirname, '../config/config.env')});

// interface ProcessEnv {
//   NODE_ENV: string | undefined;
//   PORT: number | undefined;
//   RABBIT_URL: string | undefined;
//   DB_URL: string | undefined;
//   DB_USERNAME: string | undefined;
//   DB_PASSWORD: string | undefined;
// }

// interface Config {
//   NODE_ENV: string;
//   PORT: number;
//   RABBIT_URL: string;
//   DB_URL: string;
//   DB_USERNAME: string;
//   DB_PASSWORD: string;
// }

// // Loading process.env as ENV interface

// const getConfig = (): Config => {
//   // tslint:disable-next-line: no-console
//   console.log(process.env);
//   return {
//     NODE_ENV: process.env.NODE_ENV as string,
//     PORT: Number(process.env.PORT),
//     RABBIT_URL: process.env.RABBIT_URL as string,
//     DB_URL: process.env.DB_URL as string,
//     DB_USERNAME: process.env.DB_USERNAME as string,
//     DB_PASSWORD: process.env.DB_PASSWORD as string,
//   };
// };

// const getSanitzedConfig = (config: ProcessEnv): Config => {
//   for (const [key, value] of Object.entries(config)) {
//     if (value === undefined) {
//       throw new Error(`Missing key ${key} in config.env`);
//     }
//   }
//   return config as Config;
// };

// const rawConfig = getConfig();

// const sanitizedConfig = getSanitzedConfig(rawConfig);

// export default sanitizedConfig;
