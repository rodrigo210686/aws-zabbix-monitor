resource "aws_security_group" "lambda_sg" {
  name        = "Inetum-Alarm-Lambda-sg"
  description = "Allow incoming connection"
  
  /*ingress {
    description     = "Permission to Lambda connect to Zabbix proxy"
    from_port       = var.zabbix.port
    to_port         = var.zabbix.port
    protocol        = "tcp"
    cidr_blocks     = [format("%s/32", var.zabbix.host)]
  }*/

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  vpc_id = var.lambdaAlerts.vpcId
  
  tags = merge(
    var.alarm_tags,
    {
      Name = "Inetum-Alarm-Lambda-sg"
    },
  )
}