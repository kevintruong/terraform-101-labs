# main.tf

data "aws_vpc" "default_vpc" {
  default = true
}

data "aws_subnet" "default_subnet" {
  vpc_id               = data.aws_vpc.default_vpc.id
  availability_zone_id = "apse1-az1"
}

data "aws_db_instance" "default_rds_instance" {
  db_instance_identifier = "vutch-db"
}

output "default_subnet_id" {
  value = data.aws_subnet.default_subnet.id
}

output "rds_db" {
  value = data.aws_db_instance.default_rds_instance.endpoint
}
