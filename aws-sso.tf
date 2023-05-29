########################################
# Terraformできないこと
# 下記に示すものはTerraformではできないので、手動でコンソール上（IAM Identity Center）から設定する必要がある

# 1. グループの作成・削除
# 2. ユーザーの追加・削除
# 3. グループにユーザーを追加・削除
########################################

data "aws_ssoadmin_instances" "example" {}

locals {
  groups = var.aws_sso_group
  policies = {
    Admin = {
      managed  = var.aws_sso_admin_managed_policies
      customer = var.aws_sso_admin_customer_policies
    }
    Guest = {
      managed  = var.aws_sso_guest_managed_policies
      customer = var.aws_sso_guest_customer_policies
    }
    Developer = {
      managed  = var.aws_sso_developer_managed_policies
      customer = var.aws_sso_developer_customer_policies
    }
    System = {
      managed  = var.aws_sso_system_managed_policies
      customer = var.aws_sso_system_customer_policies
    }
  }
  managed_policy_attachments = flatten([
    for group, policies in local.policies : [
      for policy in policies.managed : {
        group  = group
        policy = policy
      }
    ]
  ])
  customer_policy_attachments = flatten([
    for group, policies in local.policies : [
      for policy in policies.customer : {
        group  = group
        policy = policy
      }
    ]
  ])
}

########################################
# IAM Identity Center グループを取得
########################################
data "aws_identitystore_group" "group" {
  for_each = toset(local.groups)

  identity_store_id = tolist(data.aws_ssoadmin_instances.example.identity_store_ids)[0]

  alternate_identifier {
    unique_attribute {
      attribute_path  = "DisplayName"
      attribute_value = each.value
    }
  }
}
########################################
# アクセス許可セット作成
########################################
resource "aws_ssoadmin_permission_set" "PermissionSet" {
  for_each = toset(local.groups)

  name         = each.value
  description  = each.value
  instance_arn = tolist(data.aws_ssoadmin_instances.example.arns)[0]
}
locals {
  groups_to_permission_set = var.groups_to_permission_set
  assignment = [
    for tmp in setproduct(local.groups, values(data.aws_identitystore_group.group)) : {
      group_name          = tmp[0]
      group_id            = tmp[1].group_id
      permission_set_name = local.groups_to_permission_set[tmp[0]]
    }
  ]
}
########################################
# アクセス許可セットにポリシーをアタッチ
########################################
resource "aws_ssoadmin_managed_policy_attachment" "managed_policy_attachment" {
  for_each = { for item in local.managed_policy_attachments : "${item.group}.${item.policy}" => item }

  instance_arn       = aws_ssoadmin_permission_set.PermissionSet[each.value.group].instance_arn
  managed_policy_arn = each.value.policy
  permission_set_arn = aws_ssoadmin_permission_set.PermissionSet[each.value.group].arn
}

resource "aws_ssoadmin_customer_managed_policy_attachment" "customer_policy_attachment" {
  for_each = { for item in local.customer_policy_attachments : "${item.group}.${item.policy}" => item }

  instance_arn       = aws_ssoadmin_permission_set.PermissionSet[each.value.group].instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.PermissionSet[each.value.group].arn
  customer_managed_policy_reference {
    name = split("/", each.value.policy)[1]
    path = "/"
  }
}
########################################
# IAM Identity Center グループにアクセス許可セットを関連付け
########################################
resource "aws_ssoadmin_account_assignment" "example" {
  for_each = data.aws_identitystore_group.group

  instance_arn       = aws_ssoadmin_permission_set.PermissionSet[each.key].instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.PermissionSet[each.key].arn

  principal_id   = each.value.group_id
  principal_type = "GROUP"

  target_id   = var.account_id
  target_type = "AWS_ACCOUNT"
}