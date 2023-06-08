Thực hành khai báo biến kiểu map

```hcl
variable "user_names" {
  type = map(object({
    path = string,
    tags = map(string)
  }))
```

Sau đó duyệt qua map để tạo các IAM user tương ứng
```hcl
resource "aws_iam_user" "users" {
  for_each = var.user_names
  name     = each.key
  path     = each.value.path
  tags     = each.value.tags
}
```