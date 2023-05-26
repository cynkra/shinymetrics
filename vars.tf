variable "AWS_REGION" {
  default = "eu-central-1"
}

variable "PROJ" {
  default = "shinymetrics"
}

variable "DB_INSTANCE_TYPE" {
  default = "db.t3.micro"
}

variable "APP_INSTANCE_TYPE" {
  default = "t3.micro"
}

variable "DRILL_INSTANCE_TYPE" {
  default = "t3.large"
}

variable "ZOOKEEPER_INSTANCE_TYPE" {
  default = "t3.small"
}

variable "BASTION_INSTANCE_TYPE" {
  default = "t3.micro"
}
