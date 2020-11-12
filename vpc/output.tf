output "private_subnet" {
    value = aws_subnet.private.*.id
}

output "public_subnet" {
    value = aws_subnet.public.*.id
}

output "availability_zone" {
    value = data.aws_availability_zones.available.names
}

output "aws_ami_id" {
    value = data.aws_ami.ubuntu-18.id
}

output "aws_security_group_web_servers" {
    value = aws_security_group.web_servers.id
}

output "aws_security_group_db_servers" {
    value = aws_security_group.db_servers.id
}

output "vpc_cidr" {
    value = aws_vpc.vpc.id
}