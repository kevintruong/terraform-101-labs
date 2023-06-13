variable "kdf_list" {
  type = map(object({
    kds = any
  }))
}