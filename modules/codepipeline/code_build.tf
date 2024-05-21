# ==================== IAM Roles and Policies ====================
data "aws_iam_policy_document" "codebuild_policy" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "example_codebuild_project_role" {
  name               = "appexample-dev-codebuild-role-us-east-1"
  assume_role_policy = data.aws_iam_policy_document.codebuild_policy.json
}

resource "aws_iam_policy" "codebuild_write_cloudwatch_policy" {
  name        = "appexample-dev-codebuild-policy-us-east-1"
  description = "A policy for codebuild to write to cloudwatch"
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": [
          "cloudwatch:*",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:CreateLogGroup",
          "logs:DescribeLogStreams"
        ],
        "Resource": "*",
        "Effect": "Allow"
      },
      {
        # "Action": ["s3:Get*", "s3:List*"],
        "Action": ["s3:*"],
        # "Resource": [aws_s3_bucket.codepipeline_bucket.arn],
        "Resource": "*",
        "Effect": "Allow"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_codebuild_write_cloudwatch_policy" {
  role       = aws_iam_role.example_codebuild_project_role.name
  policy_arn = aws_iam_policy.codebuild_write_cloudwatch_policy.arn
}

# ==================== CodeBuild ====================

resource "aws_codebuild_project" "example_codebuild_project" {
  name          = "appexample-dev-codebuild-us-east-1"
  description   = "Codebuild for appexample-dev"
  build_timeout = "30"
  service_role  = aws_iam_role.example_codebuild_project_role.arn
  artifacts {
    type = "CODEPIPELINE"
  }
  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:7.0"
    type                        = "LINUX_CONTAINER"
  }
  logs_config {
    cloudwatch_logs {
      group_name  = "aws/codebuild/${var.application_name}-${var.environment}-node"
    #   stream_name = "example_codebuild_project-log-stream"
    }
  }
  source {
    type = "CODEPIPELINE"
  }
}

