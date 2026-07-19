output "instance_id" { value = aws_instance.tableau.id }
output "public_ip"   { value = aws_eip.tableau_ip.public_ip }
output "private_ip"  { value = aws_instance.tableau.private_ip }