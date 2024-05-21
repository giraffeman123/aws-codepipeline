# ==================== CodePipeline ====================

resource "aws_iam_role" "codepipeline_role" {
  name = "appexample-dev-codepipeline-role"
  assume_role_policy = jsonencode({
    Version: "2012-10-17",
    Statement: [
      {
        "Sid": "",
        "Effect": "Allow",
        "Principal": {
          "Service": "codepipeline.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "codepipline_execution_policy" {
  name        = "appexample-dev-codepipeline-policy"
  description = "A policy with permissions for codepipeline"
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow"
        "Action": ["codebuild:StartBuild", "codebuild:BatchGetBuilds"],
        "Resource": "*",
      },
      {
        "Action": ["cloudwatch:*"],
        "Resource": "*",
        "Effect": "Allow"
      },
      {
        "Action": ["s3:Get*", "s3:List*", "s3:PutObject"],
        "Resource": "*",
        "Effect": "Allow"
      },
      {
        "Action": ["codedeploy:CreateDeployment", "codedeploy:GetDeploymentConfig"],
        "Resource": "*",
        "Effect": "Allow"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_codepipline_execution_policy" {
  role       = aws_iam_role.codepipeline_role.name
  policy_arn = aws_iam_policy.codepipline_execution_policy.arn
}


resource "aws_iam_policy" "codestar_connection_policy" {
  name        = "appexample-dev-codestar-connection-policy"
  description = "A policy with permissions for codestar connection"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "codestar-connections:UseConnection",
          "codedeploy:GetDeployment",
          "codedeploy:GetDeploymentConfig",
          "codedeploy:RegisterApplicationRevision",
          "codedeploy:GetApplicationRevision"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_codestar_connection_policy" {
  role       = aws_iam_role.codepipeline_role.name
  policy_arn = aws_iam_policy.codestar_connection_policy.arn
}

# ==================== Codestar Connection ====================
resource "aws_codestarconnections_connection" "codestar_connection_example" {
  name          = "appexample-dev-codestar"
  provider_type = "GitHub"
}

# ==================== Codepipeline ====================
resource "aws_codepipeline" "pipeline" {
  name     = "appexample-dev-codepipeline-us-east-1"
  role_arn = aws_iam_role.codepipeline_role.arn
  artifact_store {
    location = aws_s3_bucket.codepipeline_bucket.bucket
    type     = "S3"
  }
  stage {
    name = "Source"
    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]
      configuration = {
        ConnectionArn    = aws_codestarconnections_connection.codestar_connection_example.arn
        FullRepositoryId = var.github_repository_url # IMPORTANT: put here url of your repository ("github.com/username/repo.git")
        BranchName       = "main"
      }
    }
  }
  stage {
    name = "Build"
    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]
      version          = "1"
      configuration = {
        ProjectName = aws_codebuild_project.example_codebuild_project.name
      }
    }
  }
  stage {
    name = "Deploy"
    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "CodeDeploy"
      input_artifacts = ["build_output"]
      version         = "1"
      configuration = {
        ApplicationName  = aws_codedeploy_app.codedeploy_app.name
        DeploymentGroupName = aws_codedeploy_deployment_group.deployment_group.deployment_group_name
      }
    }
  }
}