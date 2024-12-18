data "aws_iam_policy_document" "topic" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }

    actions   = ["SNS:Publish"]
    resources = ["arn:aws:sns:*:*:${var.project}-s3-notification"]

    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values   = [data.aws_s3_bucket.target_bucket.arn]
    }
  }
}

resource "aws_sns_topic" "s3_notification_topic" {
  name         = "${var.project}-s3-notification"
  display_name = "S3 notification topic"
  policy = data.aws_iam_policy_document.topic.json
}

resource "aws_s3_bucket_notification" "bucket_notification_sns" {
  bucket = data.aws_s3_bucket.target_bucket.id

  topic {
    topic_arn     = aws_sns_topic.s3_notification_topic.arn
    events        = ["s3:ObjectCreated:*"]
  }
}
