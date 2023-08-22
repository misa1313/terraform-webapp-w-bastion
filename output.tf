output "load-balancer-dns" {
  value = aws_lb.load-balancer-lb.dns_name
}