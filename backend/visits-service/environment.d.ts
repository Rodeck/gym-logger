declare global {
    namespace NodeJS {
      interface ProcessEnv {
        NODE_ENV: string | undefined;
        PORT: string | undefined;
        RABBIT_URL: string | undefined;
        DB_URL: string | undefined;
        DB_USERNAME: string | undefined;
        DB_PASSWORD: string | undefined;
      }
    }
  }
export {};
