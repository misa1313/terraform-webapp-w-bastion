##########################################################################
# S3 bucket for config files.
##########################################################################

resource "aws_s3_bucket" "apache-buck-04" {
  bucket = "apache-buck-04"

  tags = {
    Name        = "apache-buck-04"
    Environment = "Dev"
  }
}

resource "aws_s3_object" "ansible-playbook" {
  bucket = aws_s3_bucket.apache-buck-04.id
  key    = "setup-play.yaml"
  source = "setup-play.yaml"
}

resource "aws_s3_object" "apache-index" {
  bucket = aws_s3_bucket.apache-buck-04.id
  key    = "index.html"
  source = "index.html"
}




