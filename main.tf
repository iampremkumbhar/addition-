# main.tf

provider "aws" {
  region = var.aws_region
}

# Security Group for SSH and HTTP
resource "aws_security_group" "addition_app_sg" {
  vpc_id = aws_vpc.sample_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 Instance
resource "aws_instance" "addition_app" {
  ami           = var.ami_id
  instance_type = var.instance_type
  security_groups = [aws_security_group.addition_app_sg.name]

  # Install Python, Flask, and deploy the application
  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo yum install -y python3
              python3 -m pip install flask
              echo "from flask import Flask, request, jsonify" > /home/ec2-user/app.py
              echo "app = Flask(__name__)" >> /home/ec2-user/app.py
              echo "@app.route('/add', methods=['GET'])" >> /home/ec2-user/app.py
              echo "def add():" >> /home/ec2-user/app.py
              echo "    a = int(request.args.get('a', 0))" >> /home/ec2-user/app.py
              echo "    b = int(request.args.get('b', 0))" >> /home/ec2-user/app.py
              echo "    return jsonify({'sum': a + b})" >> /home/ec2-user/app.py
              echo "if __name__ == '__main__':" >> /home/ec2-user/app.py
              echo "    app.run(host='0.0.0.0', port=5000)" >> /home/ec2-user/app.py
              nohup python3 /home/ec2-user/app.py &
              EOF

  tags = {
    Name = "AdditionAppInstance"
  }
}

output "addition_app_public_ip" {
  value = aws_instance.addition_app.public_ip
}
