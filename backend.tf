terraform {
  backend "s3" {
    bucket         = "terraform-state-shinymetrics"
    key            = "prod/terraform.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "terraform-lock"
  }
}

# terraform {
#   backend "local" {}
# }
