variable "user_names" {
  type = map(object({
    //Định nghĩa kiểu map
    path = string,
    tags = map(string)
  }))
  default = {
    "John" = {
      path = "/marketing/"
      tags = {
        "email"  = "john@acme.com"
        "mobile" = "0902209012"
      }
    }
    "Paul" = {
      path = "/sales/"
      tags = {
        "email"  = "paul@acme.com"
        "mobile" = "0902209011"
      }
    }
    "Tuan" = {
      path = "/sales/"
      tags = {
        "email"  = "paul@acme.com"
        "mobile" = "0902209011"
      }
    }
  }
}