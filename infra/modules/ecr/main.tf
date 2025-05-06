    resource "aws_ecr_repository" "example" {
      name                  = var.ecr_name # Replace with your desired repository name
      image_tag_mutability = "MUTABLE" # Or "IMMUTABLE"
      force delete = true
      image_scanning_configuration {
        scan_on_push = false
      }
    }
