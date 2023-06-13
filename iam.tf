resource "aws_iam_role" "ec2_role" {
  name = "ec2_role"

  assume_role_policy = <<-EOF
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

resource "aws_iam_role_policy" "s3_policy" {
  name = "s3_policy"
  role = aws_iam_role.ec2_role.id

  policy = <<-EOF
    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Action": [
                    "s3:*"
                ],
                "Effect": "Allow",
                "Resource": "arn:aws:s3:::${var.PROJ}"
            }
        ]
    }
EOF
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2_profile"
  role = aws_iam_role.ec2_role.name
}
