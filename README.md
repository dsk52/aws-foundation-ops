# AWSコスト通知

## 構成

```
[AWS Budgets] 
      ↓
[AWS SNS Topic]
      ↓
[AWS Chatbot] --> [Slack Channnel]
```

## 使い方

1. AWSコンソール上からAWS Chatbotを有効化しておく
    1. ワークスペースとの連携まで
2. `npm i`
3. デプロイを実行 `npm run cdk deploy`

## Terraform運用

1. `terraform/terraform.tfvars.example` を `terraform/terraform.tfvars` にコピー
2. `slack_team_id` と `slack_channel_id` を設定
3. `terraform -chdir=terraform init`
4. `terraform -chdir=terraform plan`
5. 反映が必要なら `terraform -chdir=terraform apply`
