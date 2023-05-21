region = "ap-southeast-1"

compute_ec2_instance_name      = "EC2_Level_11_HML"
compute_ec2_instance_type      = "t3.micro"
compute_ec2_instance_subnet_id = "subnet-123456789abcd"

data_s3_buckets = {
  "level-11" = {
    bucket_name             = "my-bucket-level-11-hml"
    block_public_acls       = false
    block_public_policy     = false
    ignore_public_acls      = true
    restrict_public_buckets = true
  },
  "level-11-2" = {
    bucket_name             = "my-bucket-level-11-2-hml"
    block_public_acls       = false
    block_public_policy     = false
    ignore_public_acls      = true
    restrict_public_buckets = true
  }
}