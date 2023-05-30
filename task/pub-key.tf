resource "tls_private_key" "mongo-key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
resource "aws_key_pair" "mongo-key" {
 key_name = "mongo-key"
 public_key = tls_private_key.mongo-key.public_key_openssh
 }
output "private_key_pem" {
  value = tls_private_key.mongo-key.private_key_pem
  sensitive = true
}

locals {
  private_key_path = "mongo-key.pem"
  working_dir      = "./"
  private_key_file_path = "${local.working_dir}${local.private_key_path}"
}

resource "null_resource" "save_private_key" {
  provisioner "local-exec" {
    command      = <<-EOT
      private_key=$(terraform output -raw private_key_pem)
      echo "${tls_private_key.mongo-key.private_key_pem}" > "${local.private_key_file_path}"
      sudo chmod 700 "${local.private_key_file_path}"
    EOT
    working_dir = local.working_dir
  }
  depends_on = [aws_key_pair.mongo-key]
}

