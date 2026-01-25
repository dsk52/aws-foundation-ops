resource "aws_iam_openid_connect_provider" "github_actions" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com",
  ]

  thumbprint_list = [
    "6938fd4d98bab03faadb97b34396831e3780aea1",
    "1c58a3a8518e8759bf075b76b750d4f2df264fcd",
  ]

  tags = {
    Project = "sandbox-go-function"
    Purpose = "GitHub Actions OIDC"
  }
}

resource "aws_iam_role" "about_deploy" {
  name = "about-deploy"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.github_actions.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
          StringLike = {
            "token.actions.githubusercontent.com:sub" = [
              "repo:dsk52/about:ref:refs/heads/main",
              "repo:dsk52/about:ref:refs/heads/master",
            ]
          }
        }
      }
    ]
  })

  tags = {
    Env     = "prod"
    Project = "about"
  }
}

resource "aws_iam_role_policy" "about_deploy" {
  name = "about-deploy-policy"
  role = aws_iam_role.about_deploy.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:GetBucketLocation",
        ]
        Resource = "arn:aws:s3:::daisukekonishi.com"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:PutObjectTagging",
          "s3:PutObject",
          "s3:GetObjectTagging",
          "s3:GetObject",
          "s3:DeleteObject",
        ]
        Resource = "arn:aws:s3:::daisukekonishi.com/*"
      },
      {
        Effect   = "Allow"
        Action   = "cloudfront:CreateInvalidation"
        Resource = "arn:aws:cloudfront::178083574992:distribution/E155XX968EDVQB"
      },
    ]
  })
}

resource "aws_iam_role" "sandbox_go_function_github_actions" {
  name = "sandbox-go-function-github-actions-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.github_actions.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
          StringLike = {
            "token.actions.githubusercontent.com:sub" = [
              "repo:dsk52/sandbox-go-function:*",
              "repo:dsk52/sandbox-go-function:ref:refs/heads/main",
              "repo:dsk52/sandbox-go-function:ref:refs/heads/master",
            ]
          }
        }
      }
    ]
  })

  tags = {
    Purpose = "GitHub Actions Deployment"
    Project = "sandbox-go-function"
  }
}

resource "aws_iam_policy" "sandbox_go_function_github_actions_lambda_deploy" {
  name        = "sandbox-go-function-github-actions-lambda-deploy"
  description = "Policy for GitHub Actions to deploy Lambda functions using aws-lambda-deploy action"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "lambda:UpdateFunctionConfiguration",
          "lambda:UpdateFunctionCode",
          "lambda:PublishVersion",
          "lambda:GetFunctionConfiguration",
          "lambda:CreateFunction",
        ]
        Resource = "arn:aws:lambda:us-west-2:178083574992:function:sandbox-go-function"
      },
      {
        Effect   = "Allow"
        Action   = "iam:PassRole"
        Resource = "arn:aws:iam::178083574992:role/*lambda*"
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "sandbox_go_function_github_actions_lambda_deploy" {
  role       = aws_iam_role.sandbox_go_function_github_actions.name
  policy_arn = aws_iam_policy.sandbox_go_function_github_actions_lambda_deploy.arn
}
