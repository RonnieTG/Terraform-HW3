resource "aws_s3_bucket" "nginx_access_logs" {
  bucket = "nginx-access-log-tf-hw3"
  acl    = "private"
  tags = {
    Name = "Nginx-access-log-TF-HW3"
  }
}
resource "aws_iam_role" "nginx_accesslogs_role" {
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
data "aws_iam_policy_document" "s3_nginx_logs_put_access_policy_doc" {
  statement {
    effect = "Allow"
    actions = [
      "s3:Put*",
      "s3:Get*",
      "s3:ListBucket"
    ]
    resources = [
      "${aws_s3_bucket.nginx_access_logs.arn}/*",
      aws_s3_bucket.nginx_access_logs.arn
    ]
  }
}
resource "aws_iam_policy" "s3_nginx_logs_put_access_policy" {
  name   = "s3_nginx_logs_put_access_policy"
  policy = data.aws_iam_policy_document.s3_nginx_logs_put_access_policy_doc.json
}
resource "aws_iam_role_policy_attachment" "attach_s3_access_to_nginx_role" {
  policy_arn = aws_iam_policy.s3_nginx_logs_put_access_policy.arn
  role       = aws_iam_role.nginx_accesslogs_role.name
}
resource "aws_iam_instance_profile" "web_server" {
  name = "nginx_instance_profile"
  role = aws_iam_role.nginx_accesslogs_role.name
}