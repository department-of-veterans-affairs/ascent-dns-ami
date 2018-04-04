# ---------------------------------------------------------------------------------------------------------------------
# ATTACH AN IAM POLICY THAT ALLOWS THE DNS SERVER TO AUTOMATICALLY DISCOVER OTHER INSTANCES AWS DNS NAMES
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_iam_role_policy" "discover_nodes" {
  name   = "discover_nodes"
  role   = "${var.iam_role_id}"
  policy = "${data.aws_iam_policy_document.discover_nodes.json}"
}

data "aws_iam_policy_document" "discover_nodes" {
  statement {
    effect = "Allow"

    actions = [
      "ec2:DescribeInstances",
      "ec2:DescribeTags",
      "autoscaling:DescribeAutoScalingGroups",
    ]

    resources = ["*"]
  }
}