# Auto-scalable web app with bastion host on AWS.

Terraform deployment of a webserver (Apache). This setup includes a launch configuration that runs a script to pull the necessary files from an S3 bucket and execute an ansible playbook. The instances running Apache are inside a private subnet accessible via the load balancer, and the deployment has auto-scaling configured. The instances are only accessible via SSH through a bastion host. Flow logs are enabled for both VPCs, the logs are being pushed to a Cloudwatch log group.
