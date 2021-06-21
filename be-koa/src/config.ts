// consolidate all the env vars here
export interface ConfigInterface {
  corsOrigin: string;
  jwtTokenSecret: string;
  awsRegion: string;
  port: number;
  listenAddress: string;

  UserTableName: string;
  MenuTableName: string;
  OrdersTableArn: string;
}

const config: ConfigInterface = {
  corsOrigin: process.env.ORIGIN || "*",
  jwtTokenSecret: process.env.JWT_TOKEN_SIGNING_SECRET || "",
  awsRegion: process.env.AWS_REGION || "us-east-1",
  port: Number.parseInt(process.env.PORT || "8080"),
  listenAddress: process.env.LISTEN_ADDRESS || "0.0.0.0",

  UserTableName: process.env.UserTableName || "",
  MenuTableName: process.env.MenuTableName || "",
  OrdersTableArn: process.env.OrdersTableArn || "",
};

export default config;
