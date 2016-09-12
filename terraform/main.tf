provider "aws" {
  region      = "${var.region}"
  profile     = "default"
  max_retries = 5
}

resource "aws_codedeploy_app" "demo_app" {
  name = "${var.app_name}"
}

resource "aws_iam_role_policy" "demo_policy" {
  name = "${var.app_name}"
  role = "${aws_iam_role.demo_role.id}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "autoscaling:CompleteLifecycleAction",
                "autoscaling:DeleteLifecycleHook",
                "autoscaling:DescribeAutoScalingGroups",
                "autoscaling:DescribeLifecycleHooks",
                "autoscaling:PutLifecycleHook",
                "autoscaling:RecordLifecycleActionHeartbeat",
                "ec2:DescribeInstances",
                "ec2:DescribeInstanceStatus",
                "tag:GetTags",
                "tag:GetResources"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_iam_role" "demo_role" {
  name = "${var.app_name}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "codedeploy.amazonaws.com"
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_codedeploy_deployment_group" "demo" {
  app_name              = "${aws_codedeploy_app.demo_app.name}"
  deployment_group_name = "demo"
  service_role_arn      = "${aws_iam_role.demo_role.arn}"

  ec2_tag_filter {
    key   = "Name"
    type  = "KEY_AND_VALUE"
    value = "${var.app_name}*"
  }
}

# Instance Role and Policy
resource "aws_iam_role_policy" "demo_instance_policy" {
  name = "${var.app_name}_deployaccess"
  role = "${aws_iam_role.demo_instance_role.id}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "codedeploy:GetDeploymentConfig",
            "Resource": "arn:aws:codedeploy:${var.region}:${var.account_id}:deploymentconfig:*"
        },
        {
            "Effect": "Allow",
            "Action": "codedeploy:RegisterApplicationRevision",
            "Resource": "arn:aws:codedeploy:${var.region}:${var.account_id}:application:${var.app_name}"
        },
        {
            "Effect": "Allow",
            "Action": "codedeploy:GetApplicationRevision",
            "Resource": "arn:aws:codedeploy:${var.region}:${var.account_id}:application:${var.app_name}"
        },
        {
            "Effect": "Allow",
            "Action": "codedeploy:ListApplicationRevisions",
            "Resource": "arn:aws:codedeploy:${var.region}:${var.account_id}:*"
        },
        {
            "Effect": "Allow",
            "Action": "codedeploy:CreateDeployment",
            "Resource": "arn:aws:codedeploy:${var.region}:${var.account_id}:deploymentgroup:${var.app_name}/${aws_codedeploy_deployment_group.demo.deployment_group_name}"
        },
        {
            "Effect": "Allow",
            "Action": [
              "s3:Get*",
              "s3:List*"
            ],
            "Resource": "*"
        }

    ]
}
EOF
}

resource "aws_iam_role" "demo_instance_role" {
  name = "${var.instance_role_name}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

# EC2 instance setup

resource "aws_iam_instance_profile" "iam_profile" {
  name  = "${var.instance_role_name}"
  roles = ["${aws_iam_role.demo_instance_role.name}"]
}

resource "aws_instance" "instance" {
  ami                  = "ami-6869aa05"
  instance_type        = "t2.nano"
  key_name             = "${var.key_name}"
  security_groups      = ["launch-wizard-7"]
  iam_instance_profile = "${aws_iam_role.demo_instance_role.name}"
  user_data            = "${file("user_data")}"

  tags {
    Name = "${var.app_name}"
  }
}

# User for GitHub

resource "aws_iam_user" "github_user" {
  name = "${var.app_name}_for_github"
  path = "/"
}

resource "aws_iam_access_key" "github_user" {
  user = "${aws_iam_user.github_user.name}"
}

resource "aws_iam_user_policy" "github_user" {
  name = "${var.app_name}_for_github"
  user = "${aws_iam_user.github_user.name}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "codedeploy:GetDeploymentConfig",
            "Resource": "arn:aws:codedeploy:${var.region}:${var.account_id}:deploymentconfig:*"
        },
        {
            "Effect": "Allow",
            "Action": "codedeploy:RegisterApplicationRevision",
            "Resource": "arn:aws:codedeploy:${var.region}:${var.account_id}:application:${var.app_name}"
        },
        {
            "Effect": "Allow",
            "Action": "codedeploy:GetApplicationRevision",
            "Resource": "arn:aws:codedeploy:${var.region}:${var.account_id}:application:${var.app_name}"
        },
        {
            "Effect": "Allow",
            "Action": "codedeploy:ListApplicationRevisions",
            "Resource": "arn:aws:codedeploy:${var.region}:${var.account_id}:*"
        },
        {
            "Effect": "Allow",
            "Action": "codedeploy:CreateDeployment",
            "Resource": "arn:aws:codedeploy:${var.region}:${var.account_id}:deploymentgroup:${var.app_name}/${aws_codedeploy_deployment_group.demo.deployment_group_name}"
        },
        {
            "Effect": "Allow",
            "Action": [
              "s3:Get*",
              "s3:List*"
            ],
            "Resource": "*"
        }

    ]
}
EOF
}

output "access_key_secrets" {
  value = "${aws_iam_access_key.github_user.secret}"
}
output "access_key" {
  value = "${aws_iam_access_key.github_user.id}"
}
