output "alb_security_group_id" {

  description = "ALB Security Group"

  value = aws_security_group.alb.id

}

output "tableau_security_group_id" {

  description = "Tableau Security Group"

  value = aws_security_group.tableau.id

}