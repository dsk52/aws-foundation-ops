# Terraform import commands

## Prerequisites

- Create `terraform/terraform.tfvars` from `terraform/terraform.tfvars.example`.
- Ensure AWS profile `default` exists (or update `aws_profile` and backend profile).
- Run `terraform -chdir=terraform init`.
- Set the DNS verification variables as described below before importing any resources.

## Imports

```bash
terraform -chdir=terraform import aws_iam_role.chatbot_role ChatbotStack-ChatbotRole8A87AA1F-Kor5BnZZMXBr
terraform -chdir=terraform import aws_sns_topic.budget_alerts arn:aws:sns:ap-northeast-1:178083574992:BudgetNotificationStack-BudgetAlertTopicF20DF526-fjln1hT3HCgC
terraform -chdir=terraform import aws_sns_topic_policy.budget_alerts_publish arn:aws:sns:ap-northeast-1:178083574992:BudgetNotificationStack-BudgetAlertTopicF20DF526-fjln1hT3HCgC
terraform -chdir=terraform import aws_sns_topic.health_check_us_east_1 arn:aws:sns:us-east-1:178083574992:HealthCheckNotificationStack-HealthCheckTopic4D4B188A-DL8RJOyqk6Au
terraform -chdir=terraform import aws_chatbot_slack_channel_configuration.budget_alerts arn:aws:chatbot::178083574992:chat-configuration/slack-channel/BudgetAlertsChannel

terraform -chdir=terraform import aws_route53_health_check.blog_site 1f4929bf-12af-4f08-925d-35e5065da238
terraform -chdir=terraform import aws_route53_health_check.memo_drip 3d32c2c3-7250-4247-992c-9f3b0b673942

terraform -chdir=terraform import 'aws_cloudwatch_metric_alarm.blog_site_us_east_1' 'blog.daisukekonishi.com-health-check'
terraform -chdir=terraform import 'aws_cloudwatch_metric_alarm.memo_drip_us_east_1' 'memodrip.net-health-check'

terraform -chdir=terraform import aws_budgets_budget.monthly_cost 178083574992:MonthlyCostBudget
```

## GitHub OIDC Imports

```bash
terraform -chdir=terraform import aws_iam_openid_connect_provider.github_actions arn:aws:iam::178083574992:oidc-provider/token.actions.githubusercontent.com

terraform -chdir=terraform import aws_iam_role.about_deploy about-deploy
terraform -chdir=terraform import aws_iam_role_policy.about_deploy about-deploy:about-deploy-policy

terraform -chdir=terraform import aws_iam_role.sandbox_go_function_github_actions sandbox-go-function-github-actions-role
terraform -chdir=terraform import aws_iam_policy.sandbox_go_function_github_actions_lambda_deploy arn:aws:iam::178083574992:policy/sandbox-go-function-github-actions-lambda-deploy
terraform -chdir=terraform import aws_iam_role_policy_attachment.sandbox_go_function_github_actions_lambda_deploy sandbox-go-function-github-actions-role/arn:aws:iam::178083574992:policy/sandbox-go-function-github-actions-lambda-deploy
```

## Route 53 DNSのimport

Hosted Zone `Z17CDFAFRYYD35` の既存6レコードセットを取り込みます。Hosted Zone自体とNS/SOAはimportしません。IDはAWSで確認した実値です。import前に再取得し、定義との一致、外部システムによる継続更新がないことを確認してください。

1. 検証値を取得し、Git管理外の変数ファイルに設定します。以下はリポジトリルートで実行するfish互換コマンドです。

   ```fish
   cp terraform/dns.auto.tfvars.example terraform/dns.auto.tfvars
   chmod 600 terraform/dns.auto.tfvars
   aws route53 list-resource-record-sets --hosted-zone-id Z17CDFAFRYYD35 --query 'ResourceRecordSets[?Type==`TXT` && Name==`daisukekonishi.com.`].ResourceRecords' --output json
   aws route53 list-resource-record-sets --hosted-zone-id Z17CDFAFRYYD35 --query 'ResourceRecordSets[?Type==`CNAME` && Name==`_d482ca759bf58c094690fa1fe22d15f8.daisukekonishi.com.`].ResourceRecords' --output json
   ```

   TXTは `Value` の外側のDNS引用符を除き、例のように `"google-site-verification=実際の値"` と設定します。ACMは `Value` のJSON文字列をそのまま右辺に設定します。検証トークン自体は変更しません。既存の変数ファイルがある場合はコピーで上書きせず、内容を確認して更新します。値はplanにも表示されるため、出力を公開コメントに貼り付けません。

2. `route53_imports.tf` のimport blockを使ってplanを確認します。

   ```fish
   terraform -chdir=terraform init -lockfile=readonly
   terraform -chdir=terraform fmt -check
   terraform -chdir=terraform validate
   terraform -chdir=terraform plan
   ```

   初回は `6 to import, 0 to add, 0 to change, 0 to destroy` を期待します。DNS、ヘルスチェック、アラームや他の既存resourceに変更が出る場合はapplyせず、差分を調べます。import blockの登録はplanだけではstateに保存されません。人間がplanを確認して手動applyすると登録されます。登録済みのimport blockは残しても再importされません。

3. `apply` を使わず、CLIでstateへの登録のみを行う場合は、承認後に以下を実行します。import blockとCLI importは代替手段です。既に登録済みのresourceにはCLI importを重複実行しません。

   ```fish
   terraform -chdir=terraform import aws_route53_record.apex Z17CDFAFRYYD35_daisukekonishi.com_A
   terraform -chdir=terraform import aws_route53_record.google_verification Z17CDFAFRYYD35_daisukekonishi.com_TXT
   terraform -chdir=terraform import aws_route53_record.acm_validation Z17CDFAFRYYD35__d482ca759bf58c094690fa1fe22d15f8.daisukekonishi.com_CNAME
   terraform -chdir=terraform import aws_route53_record.blog Z17CDFAFRYYD35_blog.daisukekonishi.com_CNAME
   terraform -chdir=terraform import aws_route53_record.daily Z17CDFAFRYYD35_daily.daisukekonishi.com_A
   terraform -chdir=terraform import aws_route53_record.mealselect Z17CDFAFRYYD35_mealselect.daisukekonishi.com_A
   terraform -chdir=terraform plan
   ```

   ID形式は `<zone_id>_<name>_<type>`（routing policyを使う場合はさらに `_<set_identifier>`）です。ACMレコードは名前自体が `_` で始まるため、Zone IDの後に `_` が2つ続きます。複数のA値を持つ `daily` もimportは1回です。import後は `No changes` を期待します。途中で失敗した場合はstateの登録状況を確認し、未登録の対象だけを再実行します。

参考：[AWS ProviderのRoute 53 record仕様](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record)、[Terraform importの仕様](https://developer.hashicorp.com/terraform/language/import)。
