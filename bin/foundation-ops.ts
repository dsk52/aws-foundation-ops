#!/usr/bin/env node
import * as cdk from 'aws-cdk-lib';
import { BudgetNotificationStack } from '../lib/BudgetNotificationStack';
import { ChatbotStack } from '../lib/ChatbotStack';
import { HealthCheckNotificationStack } from '../lib/HealthCheckNotificationStack';

const app = new cdk.App();
const env = { region: 'ap-northeast-1' };

const chatbotStack = new ChatbotStack(app, 'ChatbotStack', {
  env,
});

new BudgetNotificationStack(app, 'BudgetNotificationStack', {
  env,
  slackChannel: chatbotStack.slackChannel,
});

new HealthCheckNotificationStack(app, 'HealthCheckNotificationStack', {
  env,
  slackChannel: chatbotStack.slackChannel,
});
