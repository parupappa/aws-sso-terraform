# Terraform install for Mac
```bash
brew install tfenv

tfenv --version

tfenv list-remote

# 1.4.6をインストール（2023/5/22時点の最新バージョン）
tfenv install 1.4.6

# 1.4.6をデフォルトに設定
tfenv use 1.4.6
```

# Install Terraform extension for VSCode
```
名前: HashiCorp Terraform
ID: hashicorp.terraform
説明: Syntax highlighting and autocompletion for Terraform
バージョン: 2.26.1
パブリッシャー: HashiCorp
VS Marketplace リンク: https://marketplace.visualstudio.com/items?itemName=HashiCorp.terraform
```

# Terraform Command
```bash

terraform login

terraform init

terraform plan

terraform apply

# コード整形
# https://www.terraform.io/docs/commands/fmt.html
terraform fmt
```