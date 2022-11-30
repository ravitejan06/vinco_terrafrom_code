############ IAM User ##################
resource "aws_iam_user" "user" {
  name = "aurouz-test-s3-cw-user"
}

############# CloudWatch Full Access Policy Attachment ###########
resource "aws_iam_user_policy_attachment" "cloudwatch_fullaccess_policy_attachment" {
  user       = aws_iam_user.user.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchFullAccess"
}

######## S3 Full Access Policy ##############
resource "aws_iam_policy" "s3_fullaccess_policy" {
  name        = "S3_Full_Access_Policy"
  description = "S3 Full Access Policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:*"
        ]
        Effect   = "Allow"
        Resource = "arn:aws:s3:::aurouz-test-deposit-slips/*"
      },
    ]
  })
}

resource "aws_iam_user_policy_attachment" "s3_fullaccess_policy_attachment" {
  user       = aws_iam_user.user.name
  policy_arn = aws_iam_policy.s3_fullaccess_policy.arn
}

######## IAM Role for AWS Backup
resource "aws_iam_role" "aws_backup_role" {
  name = "AWSBackupRole"

  assume_role_policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Action" : "sts:AssumeRole",
          "Principal" : {
            "Service" : "backup.amazonaws.com"
          },
          "Effect" : "Allow",
          "Sid" : ""
        }
      ]
    }
  )
}
resource "aws_iam_role_policy_attachment" "auroz_test_AWSBackupServiceRolePolicyForBackup" {
  role       = aws_iam_role.aws_backup_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
}
resource "aws_iam_role_policy_attachment" "auroz_test_AWSBackupServiceRolePolicyForRestores" {
  role       = aws_iam_role.aws_backup_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForRestores"
}


############ SES IAM User ##################
resource "aws_iam_user" "ses_iam_user" {
  name = "aurouz-test-ses-user"
}


######### IAM Policy for SES User #############
resource "aws_iam_user_policy" "ses_user_policy" {
  name = "ses_user_policy"
  user = aws_iam_user.ses_iam_user.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ses:SendRawEmail",
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}
