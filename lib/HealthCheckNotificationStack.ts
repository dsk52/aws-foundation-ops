import * as cdk from 'aws-cdk-lib';
import { Stack, type StackProps } from 'aws-cdk-lib';
import type { Construct } from 'constructs';
import * as route53 from 'aws-cdk-lib/aws-route53';
import * as cloudwatch from 'aws-cdk-lib/aws-cloudwatch';
import * as actions from 'aws-cdk-lib/aws-cloudwatch-actions';
import * as sns from 'aws-cdk-lib/aws-sns';
import { SlackChannelConfiguration } from 'aws-cdk-lib/aws-chatbot';

interface HealthCheckNotificationStackProps extends StackProps {
  slackChannel: SlackChannelConfiguration;
}

export class HealthCheckNotificationStack extends Stack {
  constructor(scope: Construct, id: string, props: HealthCheckNotificationStackProps) {
    super(scope, id, props);
    const { slackChannel } = props;

    const topic = new sns.Topic(this, 'HealthCheckTopic');

    const sites: { id: string; domain: string; path: string }[] = [
      { id: 'MainSite', domain: 'daisukekonishi.com', path: '/' },
      { id: 'BlogSite', domain: 'blog.daisukekonishi.com', path: '/' },
      { id: 'MemoDrip', domain: 'memodrip.net', path: '/' },
    ];

    sites.forEach((site) => {
      const healthCheck = new route53.CfnHealthCheck(this, `${site.id}HealthCheck`, {
        healthCheckConfig: {
          type: 'HTTPS',
          fullyQualifiedDomainName: site.domain,
          resourcePath: site.path,
          port: 443,
          failureThreshold: 3,
          requestInterval: 30,
        },
        healthCheckTags: [
          {
            key: 'Name',
            value: `${site.id}`,
          },
        ],
      });

      const alarm = new cloudwatch.Alarm(this, `${site.id}Alarm`, {
        alarmName: `${site.domain}-health-check`,
        metric: new cloudwatch.Metric({
          namespace: 'AWS/Route53',
          metricName: 'HealthCheckStatus',
          dimensionsMap: {
            HealthCheckId: healthCheck.attrHealthCheckId,
          },
          statistic: 'Minimum',
          period: cdk.Duration.minutes(1),
        }),
        threshold: 1,
        evaluationPeriods: 2,
        comparisonOperator: cloudwatch.ComparisonOperator.LESS_THAN_THRESHOLD,
      });

      alarm.addAlarmAction(new actions.SnsAction(topic));
    });

    slackChannel.addNotificationTopic(topic);
  }
}
