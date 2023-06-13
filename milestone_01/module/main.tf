# main.tf

variable "ec2_instance_type" {
  description = "EC2 instance type"
  default     = "t2.xlarge"
}

variable "ec2_ami_id" {
  description = "EC2 AMI ID which depend on region at https://cloud-images.ubuntu.com/locator/ec2/"
  default     = "ami-0ff89c4ce7de192ea"
  type        = string
}


variable "rds_instance_type" {
  description = "RDS instance type"
  default     = "db.t3.micro"
}

variable "db_name" {
  description = "Name of the RDS database"
  default     = "mydb"
}

variable "db_username" {
  description = "Username for the RDS database"
  default     = "vutch"
}

variable "db_password" {
  description = "Password for the RDS database"
  default     = "password123"
}

resource "aws_security_group" "ec2_rds_access" {
  name        = "ec2-rds-access"
  description = "Security group for EC2 to RDS access"
  vpc_id      = data.aws_vpc.default_vpc.id

  ingress {
    from_port       = 5432  # Replace with the appropriate port for your RDS
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.rds_security_group.id]
  }

  # Additional security group rules go here
}

resource "aws_security_group" "rds_security_group" {
  name        = "rds-security-group"
  description = "Security group for RDS access"

  # Define the necessary inbound rules for your RDS
  ingress {
    from_port   = 5432  # Replace with the appropriate port for your RDS
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Restrict this to specific IP ranges if desired
  }

  # Additional security group rules go here
}

data "aws_vpc" "default_vpc" {
  default = true
}

data "aws_subnet" "default_subnet" {
  vpc_id               = data.aws_vpc.default_vpc.id
  availability_zone_id = "apse1-az1"
}

resource "tls_private_key" "pk" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

variable "keyname" {
  description = "SSH key name"
  default     = "private_key"
}
resource "aws_key_pair" "generated_key" {
  key_name   = var.keyname
  public_key = "${tls_private_key.pk.public_key_openssh}"

  provisioner "local-exec" {
    # Create keypair to your computer!!
    command = <<EOT
              rm -f ./${var.keyname}.pem
              echo '${tls_private_key.pk.private_key_pem}' > ./${var.keyname}.pem
              chmod 400 ${var.keyname}.pem
              EOT
  }
}


resource "aws_instance" "ec2_instance" {
  ami                    = var.ec2_ami_id  # Replace with your desired AMI ID
  instance_type          = var.ec2_instance_type
  subnet_id              = data.aws_subnet.default_subnet.id
  vpc_security_group_ids = [aws_security_group.ec2_rds_access.id, aws_security_group.ping_ssh.id]
  key_name               = aws_key_pair.generated_key.key_name

  # Additional EC2 configuration goes here
}


resource "aws_db_instance" "rds_instance" {
  identifier              = "vutch-db"
  engine                  = "postgres"  # Replace with your desired database engine
  instance_class          = var.rds_instance_type
  username                = var.db_username
  password                = var.db_password
  allocated_storage       = 20  # Replace with your desired storage size
  storage_type            = "gp2"
  db_name                 = var.db_name
  vpc_security_group_ids  = [aws_security_group.rds_security_group.id]
  skip_final_snapshot     = "true"
  backup_retention_period = 0
}


resource "aws_security_group" "ping_ssh" {
  name = "ec2_ping_ssh"

  ingress {
    //ICMP Ping
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    //SSH
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    //Allow all outbound ports
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "ssh_ec2_instance" {
  value = "ssh -i '${var.keyname}.pem' ubuntu@${aws_instance.ec2_instance.public_ip}"
}

output "ec2_instance_public_ip" {
  value = aws_instance.ec2_instance.public_ip
}


output "rds_instance" {
  value = aws_db_instance.rds_instance.endpoint
}