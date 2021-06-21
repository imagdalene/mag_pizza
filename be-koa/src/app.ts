import { createServer } from "http";

import chalk from "chalk";
import Koa from "koa";
import cors from "koa2-cors";

import ratelimit from "koa-ratelimit";
import bodyParser from "koa-bodyparser";
import { createTerminus } from "@godaddy/terminus";
import { logger } from "./middleware/logger";
import config from "./config";

const { corsOrigin } = config;

const app = new Koa();

app.use(bodyParser());
app.use(
  cors({
    origin: corsOrigin,
    exposeHeaders: [
      "WWW-Authenticate",
      "Server-Authorization",
      "Access-Control-Allow-Origin",
    ],
    // maxAge: 5,
    credentials: true,
    allowMethods: ["OPTIONS", "GET", "POST", "PUT", "DELETE"],
    allowHeaders: ["Content-Type", "Authorization", "Accept", "Content-length"],
  })
);

app.use(
  ratelimit({
    driver: "memory",
    db: new Map(),
    errorMessage: "Chill, dude",
    duration: 10000,
    max: 20,
    id: (ctx) => ctx.ip,
  })
);

// app.use(routes);

async function onHealthCheck(): Promise<{ time: string }> {
  return {
    time: `Time By Raymond Weil:  ${Date.now()}`,
  };
}

export const server = createTerminus(createServer(app.callback()), {
  // Health check options
  healthChecks: {
    "/health": onHealthCheck,
  },

  // Graceful shutdown options
  timeout: 3000,
  beforeShutdown,
  signals: ["SIGTERM", "SIGINT", "SIGHUP"],
});

async function beforeShutdown(): Promise<void> {
  // should shut down all connections but eh using DynamoDB so *shruggie*
  logger.info("K Thanks Bye");
}

export const startServer = async (port?: number): Promise<void> => {
  await new Promise((resolve, reject) => {
    server.listen(config.port, config.listenAddress, async () => {
      try {
        const address = server.address();

        logger.info(
          `Server listening on ${config.listenAddress}:${port || config.port}`
        );
        resolve(null);
      } catch (err) {
        reject(err);
      }
    });
  });
};
