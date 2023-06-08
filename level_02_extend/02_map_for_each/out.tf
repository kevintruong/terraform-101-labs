output "paul_arn" {
  value       = aws_iam_user.users["Paul"].arn
  description = "The ARN for user Paul"
}

output "all_arns" {
  value       = aws_iam_user.users[*]
  description = "The ARNs for all users"
}