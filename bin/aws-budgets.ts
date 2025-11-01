import * as cdk from 'aws-cdk-lib';
import { S3BucketStack } from '../lib/S3BucketStack';

const ENVIRONMENTS = ["STG", "PROD"] as const;
type Environment = (typeof ENVIRONMENTS)[number];

const validateEnvironment = (): Environment => {
  const envKey = (new cdk.App().node.tryGetContext("environment") as Environment) || "STG";

  if (!ENVIRONMENTS.includes(envKey)) {
    throw new Error(
      `Invalid environment specified. Please use one of the following: ${ENVIRONMENTS.join(", ")}.
Example: cdk deploy -c environment=STG`
    );
  }
  return envKey;
};

const environment = validateEnvironment();

type AppEnv = "STG" | "PROD";

type AppConfig = {
  NAME: string;
  BRANCH: string;
  FRAMEWORK: 'astro' | 'default';
};

const APP_CONFIG: Record<AppEnv, AppConfig> = {
  STG: { NAME: "sandbox-stg-app", BRANCH: "develop", FRAMEWORK: "astro" },
  PROD: { NAME: "sandbox-prod-app", BRANCH: "main", FRAMEWORK: "astro" },
};

export const VARIABLES_CONFIG = (env: AppEnv) => {
  const { NAME, BRANCH, FRAMEWORK } = APP_CONFIG[env];

  return {
    APP_NAME: NAME,
    APP_BRANCH: BRANCH,
    APP_FRAMEWORK: FRAMEWORK,
  };
}

const app = new cdk.App();
new S3BucketStack(app, `S3BucketStack-${environment}`, {
  variables: VARIABLES_CONFIG(environment),
  env: {
    region: 'ap-northeast-1'
  },
});
