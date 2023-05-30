resource "aws_route53_zone" "php-database" {
  name = "db-dbox.com"
  vpc {
    vpc_id     = aws_vpc.database_vpc.id
    vpc_region = "ap-south-1"
  }
}
resource "aws_route53_record" "mongodb_records-1" {
  ttl     = 120
  zone_id = aws_route53_zone.php-database.id
  name    = "mongo-0.database.darwinbox.local"
  type    = "A"

  records = [aws_instance.mongodb_instance[0].private_ip]
}

resource "aws_route53_record" "mongodb_records-2" {
  ttl     = 120
  zone_id = aws_route53_zone.php-database.id
  name    = "mongo-1.database.darwinbox.local"
  type    = "A"

  records = [aws_instance.mongodb_instance[1].private_ip]
}

resource "aws_route53_record" "mongodb_records-3" {
  ttl     = 120
  zone_id = aws_route53_zone.php-database.id
  name    = "mongo-2.database.darwinbox.local"
  type    = "A"

  records = [aws_instance.mongodb_instance[2].private_ip]
}

