# variables.tfはvariable(変数)の宣言を行うところです。
variable "region" {
  description = "AWS region"
  default     = "ap-northeast-1"
}
# terraform cloudから取得
variable "AWS_ACCESS_KEY_ID" {}
variable "AWS_SECRET_ACCESS_KEY" {}

variable "account_id" {
  description = "The ID of the AWS account"
  type        = string
  # 12桁のアカウントID
  default     = "xxxxxxxxxxxx"
}


########################################
# IAM Identity Centerのグループ・許可セットを定義
# グループには同名の許可セットを関連付ける
########################################
variable "aws_sso_group" {
  description = "The list of identity store group"
  type        = list(string)
  default     = ["Admin", "Guest", "Developer", "System"]
  // Add more if needed
}

variable "groups_to_permission_set" {
  type = map(any)
  default = {
    Admin     = "Admin"
    Guest     = "Guest"
    Developer = "Developer"
    System    = "System"
    // Add more if needed
  }
}
########################################
# グループごとに使用するポリシーのarnを指定
# managedポリシーとカスタマー管理ポリシーでは作成するresourceが異なるので、それぞれvariableを用意
########################################
## Admin
variable "aws_sso_admin_managed_policies" {
  description = "The list of admin managed policies"
  type        = list(string)
  default = [
    "arn:aws:iam::aws:policy/AdministratorAccess"
  ]
}
variable "aws_sso_admin_customer_policies" {
  description = "The list of admin customer policies"
  type        = list(string)
  default     = []
}
## Guest
variable "aws_sso_guest_managed_policies" {
  description = "The list of guest managed policies"
  type        = list(string)
  default = []
}
variable "aws_sso_guest_customer_policies" {
  description = "The list of guest customer policies"
  type        = list(string)
  default = []
}
## Developer
variable "aws_sso_developer_managed_policies" {
  description = "The list of developer managed policies"
  type        = list(string)
  default = []
}
variable "aws_sso_developer_customer_policies" {
  description = "The list of developer customer policies"
  type        = list(string)
  default = []
}
## System
variable "aws_sso_system_managed_policies" {
  description = "The list of system managed policies"
  type        = list(string)
  default = []
}

variable "aws_sso_system_customer_policies" {
  description = "The list of system customer policies"
  type        = list(string)
  default = []
}
