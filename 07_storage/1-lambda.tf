data "archive_file" "move_s3_object_archive_file" {
  type        = "zip"
  source_file = "lambda/move_s3_object.py"
  output_path = "lambda/move_s3_object.zip"
}

data "aws_iam_role" "lab_role" {
  name = "LabRole"
}

resource "aws_lambda_function" "move_s3_object_lambda" {
  function_name    = "${var.project}-move-s3-object"
  role             = data.aws_iam_role.lab_role.arn
  filename         = data.archive_file.move_s3_object_archive_file.output_path
  handler          = "move_s3_object.lambda_handler"
  source_code_hash = data.archive_file.move_s3_object_archive_file.output_base64sha256
  runtime          = "python3.9"

  tags = {
    Name = "${var.project}-move-s3-object"
  }
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = data.aws_s3_bucket.source_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.move_s3_object_lambda.arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [aws_lambda_permission.allow_bucket]
}

resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.move_s3_object_lambda.arn
  principal     = "s3.amazonaws.com"
  source_arn    = data.aws_s3_bucket.source_bucket.arn
}
