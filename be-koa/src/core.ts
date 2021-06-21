import { Context } from "koa";
import jwt from "jsonwebtoken";
import bcrypt from "bcrypt";

import { logger } from "./middleware/logger";

import config from "./config";

import { GetUserByEmail, UserInterface } from "./controllers/User";

const { jwtTokenSecret } = config;

if (!jwtTokenSecret) {
  console.log(
    "Must set environment variable JWT_TOKEN_SIGNING_SECRET or we cannot protect our APIs!"
  );
  process.exit(1);
}

export interface ErrorInterface {
  status: 401;
  body: { error: string; details: string };
}

interface AssertBody {
  humanReadableError: string;
  [key: string]: unknown;
}

export const assert = (
  test: boolean,
  status: number,
  body: AssertBody
): void => {
  if (test) {
    return;
  }

  throw { status, body };
};

export const unauthorizedError: ErrorInterface = {
  status: 401,
  body: { error: "UNAUTHORIZED", details: "Invalid credentials" },
};

export const secret = Buffer.from(jwtTokenSecret, "base64");

export type UserID = string & { __brand: "UserID" };

export async function authenticateLocal({
  email,
  password,
}): Promise<[ErrorInterface, Omit<UserInterface, "passwordHash">]> {
  const userResult = await GetUserByEmail(email);
  userResult;
  if (userResult) {
    return new Promise((resolve, reject) => {
      bcrypt.compare(
        password,
        userResult.passwordHash,
        function (err, result: boolean) {
          if (err) {
            // not a no-match but an error from bad mechanism.
            // rejection results in 500 error which is correct
            reject([err, null]);
          } else if (result) {
            userResult.accessToken = signSecret(userResult.email);
            const { passwordHash, ...otherFields } = userResult;
            logger.log({
              level: "info",
              id: email,
              message: `Successfully authenticated ${email} with ${result}`,
            });
            resolve([null, { ...otherFields }]);
          } else {
            // resolve this and return 401 at the route
            resolve([unauthorizedError, null]);
          }
        }
      );
    });
  } else {
    // eventually read the logs somewhere to stop repeat fails
    logger.warn(`Login failed with email ${email}`);
    return [unauthorizedError, null];
  }
}

export function signSecret(resourceId: string): string {
  return jwt.sign({}, secret, { subject: resourceId });
}
