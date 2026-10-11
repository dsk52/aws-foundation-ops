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

## Terraform運用

1. `terraform/terraform.tfvars.example` を `terraform/terraform.tfvars` にコピー
2. `slack_team_id` と `slack_channel_id` を設定
3. `terraform/dns.auto.tfvars.example` を `terraform/dns.auto.tfvars` にコピーし、既存DNSの検証値を設定（取得方法は [import手順](terraform/imports.md#route-53-dnsのimport) を参照）
4. `terraform -chdir=terraform init`
5. `terraform -chdir=terraform plan`
6. 人間がplanを確認し、反映が必要なら `terraform -chdir=terraform apply`

## DNS管理

`daisukekonishi.com` の既存Hosted Zoneはdata参照のみで、Zone自体、NS/SOA、DNSSECはTerraform管理対象外です。`memodrip.net` のDNSも対象外です。

管理対象はapexのCloudFront Alias AとGoogle検証TXT、ACM検証CNAME、`blog` CNAME、`daily` A、`mealselect` Aの6レコードセットです。`daily` のAレコード2値は1つのresourceで管理します。ACM検証CNAMEは証明書の自動更新に必要なため保持します。

検証値を入れる `terraform/dns.auto.tfvars` はGit管理外です。TXTはDNSの外側の二重引用符を除いた値、ACMのCNAME先は末尾のドットを含む値を設定します。ProviderはTXTの読み取り時に外側の引用符を除き、書き込み時に戻すため、この表現で既存値を維持します。これらは公開DNSの検証値ですが、Gitには保存しません。import時の機密属性だけの更新差分を避けるため、変数には `sensitive` を付けていません。検証値が表示されるplanの出力や、state、保存したplanはIssueやPRに添付しないでください。

既存レコードは [import手順](terraform/imports.md#route-53-dnsのimport) に従ってstateへ登録してから運用します。通常の追加・更新はTerraform定義を変更し、fmt・validate・planの後、人間が確認してapplyします。既存レコードを追加で管理する場合は現物の名前・type・TTL・値・routing policyを確認して定義し、importを先に行います。`allow_overwrite` による上書きでimportを代替しません。

管理対象をAWSコンソールや外部サービスから変更すると、次のplanでTerraform定義との差分になります。緊急の手動変更後は、次のapply前に定義と変数を実際の値に合わせてください。外部システムが継続更新するレコードは二重管理しない方針です。今回の調査では直近90日の変更履歴にイベントがありませんでしたが、外部更新設定の有無は未確認です。import前に所有者と継続更新の有無を確認し、継続更新が必要な場合は管理対象の定義とimport blockから除外します。
