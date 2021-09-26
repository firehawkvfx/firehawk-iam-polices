terraform {
  required_version = ">= 0.13.5"
}

resource "aws_iam_role_policy" "get_sesi_api_key" {
  name = var.name
  role = var.iam_role_id
  policy = data.aws_iam_policy_document.get_sesi_api_key.json
}

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "get_sesi_api_key" {
  # API Client ID is not secret - stored as a paremeter
  statement {
    effect = "Allow"
    actions = [
      "ssm:DescribeParameters",
    ]
    resources = ["*"]
  }
  statement {
    effect = "Allow"
    actions = [
      "ssm:GetParameters",
    ]
    resources = ["arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/firehawk/resourcetier/dev/sesi_client_id"]
  }
  # API Secret however is aquired from secrets manager 
  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:ListSecrets",
    ]
    resources = ["*"]
  }
  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:GetResourcePolicy",
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
      "secretsmanager:ListSecretVersionIds"
    ]
    resources = ["arn:aws:secretsmanager:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:secret:/firehawk/resourcetier/dev/sesi_client_secret_key-*"]
  }
}