import { createServer } from 'http';

import chalk from 'chalk';
import Koa from 'koa';
import cors from 'koa2-cors';

import ratelimit from 'koa-ratelimit';
import bodyParser from 'koa-bodyparser';
import { createTerminus, HealthCheckError } from '@godaddy/terminus';

const app = new Koa()

app.use(bodyParser());
app.use(
  cors({
    origin: process.env.Origin || "*",
    exposeHeaders: ['WWW-Authenticate', 'Server-Authorization', 'Access-Control-Allow-Origin'],
    // maxAge: 5,
    credentials: true,
    allowMethods: ['OPTIONS', 'GET', 'POST', 'PUT', 'DELETE'],
    allowHeaders: ['Content-Type', 'Authorization', 'Accept', 'Content-length'],
  })
);
