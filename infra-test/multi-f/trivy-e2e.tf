resource "aws_ecr_repository" "trivy_e2e_mutable_tags" {
  name                 = "${local.name_prefix}-trivy-e2e"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}
