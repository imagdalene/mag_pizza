// consolidate all the env vars here
export interface ConfigInterface {
  corsOrigin: string;
  jwtTokenSecret: string;
  awsRegion: string;
  UserTableName: string;
  MenuTableName: string;
  OrdersTableArn: string;
}

const config: ConfigInterface = {
  corsOrigin: process.env.ORIGIN || "*",
  jwtTokenSecret: process.env.JWT_TOKEN_SIGNING_SECRET,
  awsRegion: process.env.AWS_REGION,
  UserTableName: process.env.UserTableName,
  MenuTableName: process.env.MenuTableName,
  OrdersTableArn: process.env.OrdersTableArn,
};

export default config;
