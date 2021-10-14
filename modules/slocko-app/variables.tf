variable "vpc" {
  type = string
}

variable "name" {
  type = string
}

variable "subnet_cidr" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "Key_name" {
  type = string
}

variable "public_key" {
  type = string
}