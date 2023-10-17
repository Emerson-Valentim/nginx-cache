resource "aws_instance" "app" {
  ami           = "ami-041feb57c611358bd"
  instance_type = "t2.micro"
  key_name      = var.key_pair_name

  tags = {
    project = "nginx-cache"
  }

  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.security_group_ids

  associate_public_ip_address = true
  user_data_replace_on_change = true

  user_data = <<-EOF
  #!/bin/bash
  sudo su -

  sudo yum -y install nodejs
  sudo yum -y install git

  sudo mkdir -p -m 777 /usr/app
  git clone https://github.com/Emerson-Valentim/nginx-cache.git
  cd nginx-cache && npm install;
  npm run build && mv ./dist/main.js /usr/app/
  cd .. && rm -rf nginx-cache
  PORT=1000 node /usr/app/main.js
  EOF
}
