# Orchestration for the module
resource "aws_eip" "tableau_ip" {
  instance = aws_instance.tableau.id
  domain   = "vpc"
}