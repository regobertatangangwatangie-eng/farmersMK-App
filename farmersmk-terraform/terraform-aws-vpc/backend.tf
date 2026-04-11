terraform {
  backend "s3" {
    bucket = "farmersmk-app"
    key    = "terraform/terraform.tfstate"
    region = "us-east-1"
  }
}
