# EC2 basic site + Elastic Load Balancer (ELB)

Basic usage of EC2 instances and ELB.

## Steps

    1. Create basic EC2 instance
    2. Manually install nginx and set a basic "EC2 instance 1/2"
    3. Deploy an ELB
    4. Test the balancer if you are accessing one EC2 or the other. 
    5. Retry with Terraform
    6. Document the process along the way.

## Inventory

    - 2 EC2 instances
    - 2 basic nginx and index.html 
    - 1 VPC
    - 2 Subnets (A and B)
    - 1 ELB (ALB) 
    - 1 Target group
    - 1 Certificate for HTTPS. Must be in same region, not like CloudFront in us-east-1.
    - A security group for HTTPS inbound and outbound in the ELB

### Sensitive variables 

I use a "sensitive.tfvars" in the .terraform folder that is not uploaded to the repo with the tfstate. Then use it to plan and apply on terraform to hide sensitive data. 

- `hosted_zone_id` - The hosted_zone_id of the domain. Can get it with aws cli: `aws route53 list-hosted-zones`
- `cert_arn` The arn of the certificate. `aws acm list-certificates` (in the us-east-1 region).

## Basic nginx deployment

`sudo yum update -y`
`sudo yum install nginx -y`
`sudo systemctl start nginx`
`sudo systemctl enable nginx`
`echo '<html><body><h1>Hello from ${var.instance_name}!</h1><p>Refresh this page! It's an aplication load balancer.</p></body></html>' | sudo tee /usr/share/nginx/html/index.html > /dev/null`