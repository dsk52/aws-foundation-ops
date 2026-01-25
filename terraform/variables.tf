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
