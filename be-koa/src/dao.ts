import { PromiseResult } from "aws-sdk/lib/request";

import {
  AWSError,
  DynamoDB,
  CredentialProviderChain,
  Credentials,
  ECSCredentials,
} from "aws-sdk";

import { logger } from "./middleware/logger";

import config from "./config";

const { awsRegion } = config;

export async function GetAWSCredentials(): Promise<Credentials> {
  const providers = [() => new ECSCredentials()];
  const creds = new CredentialProviderChain(providers);
  const resolvedCreds = await creds.resolvePromise().catch((err) => {
    logger.error(err);
    throw err;
  });
  logger.info("Creds Resolved");
  return resolvedCreds;
}

export async function GetDynamoDBClientInstance(): Promise<DynamoDB.DocumentClient> {
  logger.info("geting dynamoDB client");
  return new DynamoDB.DocumentClient({
    credentials: await GetAWSCredentials(),
    region: awsRegion,
  });
}

export async function CreateItem(params: DynamoDB.DocumentClient.PutItemInput) {
  const client = await GetDynamoDBClientInstance();
  return await client
    .put(params)
    .promise()
    .then(
      async (
        result: PromiseResult<DynamoDB.DocumentClient.PutItemOutput, AWSError>
      ) => {
        if (result.$response.error) {
          logger.error(result.$response.error);
          throw result.$response.error;
        }

        return result.$response.data;
      }
    );
}

export async function GetItem(
  params: DynamoDB.DocumentClient.GetItemInput
): Promise<unknown> {
  const client = await GetDynamoDBClientInstance();
  return await client
    .get(params)
    .promise()
    .then(
      async (
        result: PromiseResult<DynamoDB.DocumentClient.GetItemOutput, AWSError>
      ) => {
        if (result.$response.error) {
          logger.error(result.$response.error);
          throw result.$response.error;
        }

        return result.$response.data;
      }
    );
}

export async function DeleteItem(
  params: DynamoDB.DocumentClient.DeleteItemInput
) {
  const client = await GetDynamoDBClientInstance();
  return await client
    .delete(params)
    .promise()
    .then(
      async (
        result: PromiseResult<
          DynamoDB.DocumentClient.DeleteItemOutput,
          AWSError
        >
      ) => {
        if (result.$response.error) {
          logger.error(result.$response.error);
          throw result.$response.error;
        }

        return result.$response.data;
      }
    );
}

export async function UpdateItem(
  params: DynamoDB.DocumentClient.UpdateItemInput
) {
  const client = await GetDynamoDBClientInstance();
  return await client
    .update(params)
    .promise()
    .then(
      async (
        result: PromiseResult<
          DynamoDB.DocumentClient.UpdateItemOutput,
          AWSError
        >
      ) => {
        if (result.$response.error) {
          logger.error(result.$response.error);
          throw result.$response.error;
        }

        return result.$response.data;
      }
    );
}
