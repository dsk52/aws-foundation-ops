variable "aws_profile" {
  type        = string
  description = "AWS CLI profile name to use for providers and backend."
  default     = "default"
}

variable "slack_team_id" {
  type        = string
  description = "Slack team/workspace ID for AWS Chatbot."
}

variable "slack_channel_id" {
  type        = string
  description = "Slack channel ID for AWS Chatbot."
}

variable "route53_google_verification_record" {
  type        = string
  description = "Existing Google verification TXT value without the surrounding DNS double quotes."
}

variable "route53_acm_validation_target" {
  type        = string
  description = "Existing ACM validation CNAME target, including its trailing dot."
}
