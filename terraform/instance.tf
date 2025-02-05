resource "aws_instance" "web" {

  ami                    = data.aws_ami.amiID.id
  instance_type          = "t3.micro"
  key_name               = "dv-key"
  vpc_security_group_ids = [aws_security_group.dv-sg.id]
  availability_zone      = "us-east-1a"

  tags = {
    Name    = "dv-web"
    Project = "dv"
  }

}

resource "aws_ec2_instance_state" "web-state" {
  instance_id = aws_instance.web.id
  state       = "running"
}