ref: https://registry.terraform.io/modules/terraform-aws-modules/security-group/aws/latest
ref: https://github.com/terraform-aws-modules/terraform-aws-security-group/tree/master/examples/http
List of Security Groups implemented as Terraform modules: https://github.com/terraform-aws-modules/terraform-aws-security-group/blob/master/modules/README.md
#rules - Map of known security group rules (define as 'name' = ['from port', 'to port', 'protocol', 'description']). 

Security group with predefined rules

module "http_80_security_group" {
  source  = "terraform-aws-modules/security-group/aws//modules/http-80"
  version = "~> 4.0"

  name = "http_80"
  vpc_id = module.vpc.vpc_id
  ingress_cidr_blocks = ["10.0.3.0/24"] #Use the cidr block of the subnet the security group will be deployed in.
  ingress_rules = ["http-80-tcp"]
  computed_ingress_rules           = ["ssh-tcp", "https-443-tcp", "http-8080-tcp"] #Use this line to add more security group rules to the default http 80 rule.
  number_of_computed_ingress_rules = 2
}

variable "auto_ingress_with_self" {
  description = "List of maps defining ingress rules with self to add automatically"
  type        = list(map(string))
  default     = [{ "rule" = "all-all" }]
}
  
module "ssh_security_group" {
  source  = "terraform-aws-modules/security-group/aws//modules/ssh"
  version = "~> 4.0"

  name = "ssh-sg"
  vpc_id = module.vpc.vpc_id
  ingress_cidr_blocks = ["10.0.3.0/24"] #Use the cidr block of the subnet the security group will be deployed in.
  ingress_rules = ["ssh-tcp"]
}
  
module "https_443_security_group" {
  source  = "terraform-aws-modules/security-group/aws//modules/https-443"
  version = "~> 4.0"

  name = "https-sg"
  vpc_id = module.vpc.vpc_id
  ingress_cidr_blocks = ["10.0.3.0/24"] #Use the cidr block of the subnet the security group will be deployed in.
  ingress_rules = ["https-443-tcp"]
}

module "http_8080_security_group" {
  source  = "terraform-aws-modules/security-group/aws//modules/http-8080"
  version = "~> 4.0"

  vpc_id = module.vpc.vpc_id
  ingress_cidr_blocks = ["10.0.3.0/24"] #Use the cidr block of the subnet the security group will be deployed in.
  ingress_rules = ["http-8080-tcp"] #port for tomcat and jenkins
}
module "mysql_security_group" {
  source  = "terraform-aws-modules/security-group/aws//modules/mysql"
  version = "~> 4.0"

  name = "mysql-sg"
  vpc_id = module.vpc.vpc_id
  ingress_cidr_blocks = ["10.0.3.0/24"] #Use the cidr block of the subnet the security group will be deployed in.
  ingress_rules = ["mysql-tcp"]
}
  
module "mongodb_security_group" {
  source  = "terraform-aws-modules/security-group/aws//modules/mongodb"
  version = "~> 4.0"

  vpc_id = module.vpc.vpc_id
  ingress_cidr_blocks = ["10.0.3.0/24"] #Use the cidr block of the subnet the security group will be deployed in.
  ingress_rules = ["mongodb-27017-tcp"]
}

module "elasticsearch_security_group" {
  source  = "terraform-aws-modules/security-group/aws//modules/elasticsearch"
  version = "~> 4.0"

  name = "elasticsearch-sg"
  vpc_id = module.vpc.vpc_id
  ingress_cidr_blocks = ["10.0.3.0/24"] #Use the cidr block of the subnet the security group will be deployed in.
  ingress_rules = ["elasticsearch-java-tcp"]
}
  
module "kibana_security_group" {
  source  = "terraform-aws-modules/security-group/aws//modules/kibana"
  version = "~> 4.0"

  name = "kibana-sg"
  vpc_id = module.vpc.vpc_id
  ingress_cidr_blocks = ["10.0.3.0/24"] #Use the cidr block of the subnet the security group will be deployed in.
  ingress_rules = ["kibana-tcp"]
}
  
module "prometheus_security_group" {
  source  = "terraform-aws-modules/security-group/aws//modules/prometheus"
  version = "~> 4.0"

  name = "prometheus-sg"
  vpc_id = module.vpc.vpc_id
  ingress_cidr_blocks = ["10.0.3.0/24"] #Use the cidr block of the subnet the security group will be deployed in.
  ingress_rules = ["prometheus-http-tcp"]
}
  
Security group with custom rules 
  
module "security-group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.17.2"

  name = "All-sg"
  vpc_id = module.vpc.vpc_id
  ingress_cidr_blocks = ["10.0.3.0/24"] #This should be the cidr block for the public/private subnets within your VPC that you're setting up the security group within.
  
  ingress_rules = ["all-all", "ssh-tcp", "http-80-tcp", "http-8080-tcp", "https-443-tcp", "kibana-tcp", "elasticsearch-java-tcp", 
                   "mongodb-27017-tcp", "kubernetes-api-tcp", "mysql-tcp", "prometheus-http-tcp", "prometheus-node-exporter-http-tcp", 
                   "prometheus-pushgateway-http-tcp"
                  ]
}
  
Security Group with custom rules

  module "Sonar" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "Sonar"
  description = "Security group for user-service with custom ports open within VPC"
  vpc_id      = module.vpc.vpc_id
  
  ingress_with_cidr_blocks = [
    {
      from_port   = 9000 #port for sonarqube
      to_port     = 9000
      protocol    = "tcp"
      description = "SonarQube Port"
      cidr_blocks = "0.0.0.0/0"
    },
  ]
}

module "Nexus" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "Nexus"
  description = "Security group for Nexus ports open within VPC"
  vpc_id      = module.vpc.vpc_id
  
  ingress_with_cidr_blocks = [
    {
      from_port   = 8081 #port for sonarqube
      to_port     = 8081
      protocol    = "tcp"
      description = "Nexus Port"
      cidr_blocks = "0.0.0.0/0"
    },
  ]
}

module "vote_service_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "user-service"
  description = "Security group for user-service with custom ports open within VPC, and PostgreSQL publicly open"
  vpc_id      = module.vpc.vpc_id
  
  ingress_with_cidr_blocks = [
    {
      from_port   = 9000 #port for sonarqube
      to_port     = 9000
      protocol    = "tcp"
      description = "User-service ports"
      cidr_blocks = "10.0.3.0/24"
    },
    {
      rule        = "postgresql-tcp"
      cidr_blocks = "0.0.0.0/0"
    },
  ]
}
