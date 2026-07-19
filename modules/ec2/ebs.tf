resource "aws_ebs_volume" "tableau_data" {
  availability_zone = aws_instance.tableau.availability_zone
  size              = 100
  type              = "gp3"
  tags              = local.tags
}

resource "aws_volume_attachment" "tableau_data_att" {
  device_name = "/dev/sdb"
  volume_id   = aws_ebs_volume.tableau_data.id
  instance_id = aws_instance.tableau.id
}