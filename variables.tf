variable "region" {
  default = "us-east-2"
}
variable "instance_type" {
  default = "t2.micro"
}
variable "port" {
  type    = list(any)
  default = ["22"]
}
variable "access_ip" {
  type    = list(any)
  default = [""]
}
