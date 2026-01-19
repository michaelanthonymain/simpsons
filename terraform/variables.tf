variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "domain_name" {
  description = "Domain name for Route53 hosted zone"
  type        = string
  default     = "plain-reef.jv-magic.com"
}

variable "subdomain" {
  description = "Subdomain for the application"
  type        = string
  default     = "simpsons"
}
