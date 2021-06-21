import { DynamoDB } from "aws-sdk";
import { GetItem } from "../dao";
import config from "../config";
import { logger } from "../middleware/logger";

const { UserTableName } = config;

export interface UserInterface {
  email: string;
  passwordHash: string;
  accessToken?: string;
  roles: string[];
}

export async function GetUserByEmail(email): Promise<UserInterface | void> {
  const userQueryParams: DynamoDB.DocumentClient.GetItemInput = {
    TableName: UserTableName,
    Key: email,
  };
  const queryResult = await GetItem(userQueryParams);
  logger.info(queryResult);
  return queryResult as UserInterface;
}
