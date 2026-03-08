## Setup

DevContainerによる開発環境の構築
1. VSCodeを開く
2. 左下の「><」アイコンをクリック
3. 「Reopen in Container」を選択
4. コンテナが立ち上がるまで待つ
5. ターミナルを開く


## Terraform (インフラ管理)

GCPリソースを `terraform/` ディレクトリで管理しています。

### 管理対象リソース

- Cloud Run (`ramen-ai-backend-service`)
- Artifact Registry (`cloud-run-source-deploy`)
- Secret Manager (`RAILS_MASTER_KEY`, `GCP_CLIENT_ID`, `GCP_CLIENT_SECRET`)
- Cloud Build トリガー
- IAM バインディング

### 初期セットアップ

```bash
cd terraform

# 変数ファイルを作成
cp terraform.tfvars.example terraform.tfvars  # 存在する場合

terraform init
```

### 通常の操作

```bash
# 差分確認
terraform plan

# 適用
terraform apply
```

### 注意事項

- `terraform.tfvars` はシークレットを含む可能性があるため git に含めない
- Cloud Run のコンテナイメージはCloud Buildが更新するため Terraform 管理外
- Secret の値（バージョン）は Terraform 管理外。`gcloud secrets versions add` で設定する

## API

`OPENAPI=1 bundle exec rspec`でAPIのドキュメントを生成できます。

[doc/openapi.yaml](doc/openapi.yaml) に出力されます。
