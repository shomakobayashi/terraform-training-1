locals {
  
  rdss = {
    username = "nwse_api"
    password = random_password.rds.result
    database = "coocked_aiu_nwse_db"
    engine = "mysql"
    host = replace(module.db.db_instance_endpoint, "/:.*/", "")
    port = module.db.db_instance_port
    dbClusterIdentifier = "aws-and-infra-${var.env}-db"
}

resource "random_password" "rds" {
  length           = 8
  upper            = true
  lower            = true
  numeric          = true
  special          = false
  keepers = {
    setting_date = "20240526" #原則変更しないため、設定日付を入れる
  }
}

resource "aws_secretsmanager_secret" "secret" {
  name      = "aws-and-infra-${var.env}-secret"
  kms_key_id = aws_kms.kms-secret.id
  tags = {
    Name = "aws-and-infra-${var.env}-secret"
  }
  lifecycle {
    ignore_changes = all
  }
}

resource "aws_secretsmanager_secret_version" "secret" {
  secret_id     = aws_secretsmanager_secret.secret.id
  secret_string = jsonencode({
    region = var.region,
    project = var.project,
    env = var.env,
    tag_env = var.tag_env,
    subnet_private_AZ_A = var.subnet_private_AZ_A,
    subnet_private_AZ_C = var.subnet_private_AZ_C,
    subnet_private_AZ_A3 = var.subnet_private_AZ_A3,
    subnet_private_AZ_C3 = var.subnet_private_AZ_C3
  })
  depends_on = [aws_secretsmanager_secret.secret]
  #secret値が変更されると、バージョンが変わるためリソースが再作成される。これを防ぐためignoreする。
  lifecycle {
    ignore_changes = all
  }
  
}