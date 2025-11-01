import * as cdk from 'aws-cdk-lib';

const ENVIRONMENTS = ["STG", "PROD"] as const;
type Environment = (typeof ENVIRONMENTS)[number];


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
