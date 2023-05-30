resource "aws_instance" "bastion_server" {
  ami                    = "ami-08e5424edfe926b43"  # Replace with your desired bastion server AMI
  instance_type          = "t3.medium"    # Replace with your desired instance type
  subnet_id              = aws_subnet.public_subnet_db_1.id
  vpc_security_group_ids = [aws_security_group.database-sg.id]
  key_name               = aws_key_pair.mongo-key.key_name
  tags = {
    Name = "bastion-server"
   
  }
 depends_on = [aws_route_table_association.public_subnet_db, aws_route_table_association.public_subnet_db-1]
}

resource "aws_instance" "mongodb_instance" {
  count                  = 3
  ami                    = "ami-08e5424edfe926b43"   # Replace with your desired AMI
  instance_type          = "t2.micro"                 # Replace with your desired instance type
  subnet_id              = aws_subnet.private_subnet_db_1.id
  vpc_security_group_ids = [aws_security_group.database-sg.id]
  key_name               = aws_key_pair.mongo-key.key_name
  tags = {
    Name = "mongo-instance-${count.index}"
  }
 depends_on = [aws_instance.bastion_server]
 
  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y gnupg ca-certificates",
      "wget -qO - https://www.mongodb.org/static/pgp/server-5.0.asc | sudo apt-key add -",
      "echo 'deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/5.0 multiverse' | sudo tee /etc/apt/sources.list.d/mongodb-org-5.0.list",
      "sudo apt-get update",
      "sudo apt-get install -y mongodb-org",
      "sudo systemctl enable mongod",
      "sudo sh -c 'echo ${self.private_ip}  >> /etc/hosts'",
      "sudo sed -i 's/bindIp: 127.0.0.1/bindIp: 127.0.0.1,${self.private_ip}/' /etc/mongod.conf",
      "sudo sed -i '/^#replication:/a replication:\\n  replSetName: as1' /etc/mongod.conf",
      "sudo systemctl restart mongod",
      "sleep 10"
    ]

    connection {
      type                 = "ssh"
      bastion_host         = aws_instance.bastion_server.public_ip
      bastion_user         = "ubuntu"
      bastion_private_key  = tls_private_key.mongo-key.private_key_pem
      host                 = self.private_ip
      user                 = "ubuntu"
      private_key          = tls_private_key.mongo-key.private_key_pem

      timeout              = "10m"  # Set the timeout value for the provisioner commands
    }
  }
}

resource "null_resource" "initiate_replica_set" {
  

  connection {
    type        = "ssh"
    bastion_host = aws_instance.bastion_server.public_ip
    bastion_user = "ubuntu"
    bastion_private_key = tls_private_key.mongo-key.private_key_pem
    host        = aws_instance.mongodb_instance[0].private_ip
    user        = "ubuntu"
    private_key = tls_private_key.mongo-key.private_key_pem

    timeout = "10m"
  }

  provisioner "remote-exec" {
    inline = [
      "mongosh --eval 'rs.initiate()'",
      "mongosh --eval 'rs.add(\"${element(aws_instance.mongodb_instance.*.private_ip, 1)}:27017\")'",
      "mongosh --eval 'rs.add(\"${element(aws_instance.mongodb_instance.*.private_ip, 2)}:27017\")'"
    ]
  }
  
}

resource "null_resource" "local_exec" {
  provisioner "local-exec" {
    command     = "scp -o 'StrictHostKeyChecking=no' -i 'mongo-key.pem' 'mongo-key.pem' ubuntu@${aws_instance.bastion_server.public_ip}:~/"
    working_dir = "./"
  }

   depends_on = [aws_instance.mongodb_instance]
}

