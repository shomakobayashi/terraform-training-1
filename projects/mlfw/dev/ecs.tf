resource "aws_ecs_task_definition" "mlfw_redhat" {
  family             = "aws-and-infra-${var.env}-mlfw-redhat"
  execution_role_arn = data.aws_iam_role.admin_role.arn
  task_role_arn     = data.aws_iam_role.admin_role.arn 
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu = var.mlfw_redhat_cpu
  memory = var.mlfw_redhat_memory
  skip_destroy = "true"

  container_definitions =  jsondecode(
    [{
      "name": "mlfw-redhat",
      "image": "${aws_ecr_repositry.mlfw_redhat.repository_url}:latest",
      "cpu": 0,
      "memory": var.mlfw_redhat_memory,
      "essential": true,
      "environment" : [],
      "portMappings": [],
      "volumesFrom": [],
      "logConfiguration": {
        "logDriver": "awslogs",
        "secretOptions": null,
        "options": {
          "awslogs-group": "/ecs/aws-and-infra-${var.env}-mlfw-redhat",
          "awslogs-region": "ap-northeast-1",
          "awslogs-stream-prefix": "ecs"
        }
      },
      mountPoints : [
        {
          "sourceVolume": "mlfw-&{var.env}-efs",
          "containerPath": "/efs",
          "readOnly": false
        }
      ],
    }]
  )
  volume {
    name = "mlfw-&{var.env}-efs"
    
    efs_volume_configuration {
      file_system_id     = module.efs.file_system_id
      root_directory     = "/"
      transit_encryption = "ENABLED"
    }
  }
}

resource "aws_cludwatch_log_group" "mlfw_redhat" {
  name = "/ecs/aws-and-infra-${var.env}-mlfw-redhat"
  retention_in_days = 90
  
}
