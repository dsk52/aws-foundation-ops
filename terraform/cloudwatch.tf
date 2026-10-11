resource "aws_cloudwatch_metric_alarm" "blog_site_us_east_1" {
  provider            = aws.us_east_1
  alarm_name          = "blog.daisukekonishi.com-health-check"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  threshold           = 1
  metric_name         = "HealthCheckStatus"
  namespace           = "AWS/Route53"
  statistic           = "Minimum"
  period              = 60

  dimensions = {
    HealthCheckId = aws_route53_health_check.blog_site.id
  }

  alarm_actions = [aws_sns_topic.health_check_us_east_1.arn]
}

resource "aws_cloudwatch_metric_alarm" "memo_drip_us_east_1" {
  provider            = aws.us_east_1
  alarm_name          = "memodrip.net-health-check"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  threshold           = 1
  metric_name         = "HealthCheckStatus"
  namespace           = "AWS/Route53"
  statistic           = "Minimum"
  period              = 60

  dimensions = {
    HealthCheckId = aws_route53_health_check.memo_drip.id
  }

  alarm_actions = [aws_sns_topic.health_check_us_east_1.arn]
}
