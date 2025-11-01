import { Stack, type StackProps } from 'aws-cdk-lib';
import { Construct } from 'constructs';

import { ManagedPolicy, Role, ServicePrincipal } from 'aws-cdk-lib/aws-iam';
import { SlackChannelConfiguration } from 'aws-cdk-lib/aws-chatbot';
import { SLACK } from '../constants/config';

export class ChatbotStack extends Stack {
  public readonly slackChannel: SlackChannelConfiguration;

  constructor(scope: Construct, id: string, props?: StackProps) {
    super(scope, id, props);

    const chatbotRole = new Role(this, 'ChatbotRole', {
      assumedBy: new ServicePrincipal('chatbot.amazonaws.com'),
      managedPolicies: [
        ManagedPolicy.fromAwsManagedPolicyName('ReadOnlyAccess'),
        ManagedPolicy.fromAwsManagedPolicyName('CloudWatchReadOnlyAccess'),
      ],
    });

    this.slackChannel = new SlackChannelConfiguration(this, 'SlackChannelConfig', {
      slackChannelConfigurationName: 'BudgetAlertsChannel',
      slackWorkspaceId: SLACK.workspaceId,
      slackChannelId: SLACK.channelId,
      notificationTopics: [],
      role: chatbotRole,
    });
  }
}
