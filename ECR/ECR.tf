provider "aws" {
  region = "us-east-1"  # or any region you want
}

resource "aws_ecr_repository" "my_app_repo" {
  name                 = "my-app-repo"
  image_tag_mutability = "MUTABLE"  # or "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name        = "my-app-repo"
    Environment = "dev"
  }
}

output "ecr_repo_url" {
  value = aws_ecr_repository.my_app_repo.repository_url
}
