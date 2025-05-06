terraform {
  backend "s3" {
    bucket         = "terraform-prod-state-dilshad"
     key            = "crud-app/terraform.tfstate"
    region         = "us-east-2"
    dynamodb_table = "terraform-locks"
  }
}