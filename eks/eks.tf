#Important Security Group Requirements: https://docs.aws.amazon.com/eks/latest/userguide/sec-group-reqs.html
#EKS VPC And Subnet Ref: https://docs.aws.amazon.com/eks/latest/userguide/network_reqs.html
#Ref for public and private tagging rules tied to alb controller: https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.4/deploy/subnet_discovery/
#Addons Version Ref: https://docs.aws.amazon.com/eks/latest/userguide/service-accounts.html#boundserviceaccounttoken-validated-add-on-versions
Install EBS Addon: https://dev.to/aws-builders/install-manage-amazon-eks-add-ons-with-terraform-2dea
---
Update as of 06/29/23

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.13.1"

  cluster_name = var.cluster_name
  cluster_version = var.cluster_version
  vpc_id = module.vpc.vpc_id
  subnet_ids = module.vpc.public_subnets
  cluster_endpoint_public_access = var.cluster_endpoint_public_access
  enable_irsa = var.irsa
  cluster_addons = {#Relies on default policy in module variable file that lists Worker Node, VPC-CNI, and EC2container policies. If not using the eks managed node group block, these policies need to be entered
#manually with the iam_role_additional_policies block in which the arn of the needed policies, not the arn of the roles, will be inputted in a key-value format e.g EBS = "EBSDriverPolicy arn"
    coredns = {
      most_recent = var.coredns 
    }
    kube-proxy = {
      most_recent = var.kube_proxy
    }
    vpc-cni = {
      most_recent = var.vpc_cni
    }
    aws-ebs-csi-driver = {
      most_recent = var.aws-ebs-csi-driver #Required to install EBS CSI Driver needed for provisioning EBS volumes for persistent volume storage config. This is also tied to the service account created separately
    }
  }
  
  eks_managed_node_groups = {
    Goku = {
      
      instance_types = var.instance_types
      ebs_optimized = var.ebs_optimized
      disk_size = var.disk_size
      use_custom_launch_template = var.use_custom_launch_template
      remote_access = {
                        ec2_ssh_key  = var.key_name
                      }
      iam_role_additional_policies = {
                                        EBS          = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy" #Required for Nodes to have permission to access the EBS CSI Driver addon that was installed.
                                        LoadBalancer = "arn:aws:iam::083772204804:policy/AmazonEKS_AWS_Load_Balancer_Controller-20230608112628756700000002"
                                        ExternalDNS  = "arn:aws:iam::083772204804:policy/AmazonEKS_External_DNS_Policy-20230430205147696100000003"
                                      }

      min_size     = var.min_size
      max_size     = var.max_size
      desired_size = var.desired_size
      update_config = {
                        max_unavailable = var.max_unavailable
                      }
    }
  }
  
  tags = {
    "kubernetes.io/cluster/SSJ3" = "owned"
    name = "kubernetes.io/cluster/SSJ3"
  }
}


--- 
#06/22/23

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.13.1"

  cluster_name = var.cluster_name
  cluster_version = var.cluster_version
  vpc_id = module.vpc.vpc_id
  subnet_ids = module.vpc.public_subnets
  cluster_endpoint_public_access = true
  enable_irsa = var.irsa
  cluster_addons = {
    coredns = {
      most_recent = var.coredns
    }
    kube-proxy = {
      most_recent = var.kube_proxy
    }
    vpc-cni = {
      most_recent = var.vpc_cni
    }
  }

  cluster_security_group_additional_rules = {
    # Test: https://github.com/terraform-aws-modules/terraform-aws-eks/pull/2319
                                            ingress_source_security_group_id = {
                                                  description              = "http-80"
                                                  protocol                 = "tcp"
                                                  from_port                = 80
                                                  to_port                  = 80
                                                  type                     = "ingress"
                                                  source_security_group_id = module.Default_SG.security_group_id
                                          }
                                            ingress_source_security_group_id = {
                                                 description              = "http-8080"
                                                 protocol                 = "tcp"
                                                 from_port                = 8080
                                                 to_port                  = 8080
                                                 type                     = "ingress"
                                                 source_security_group_id = module.Default_SG.security_group_id
                }
                                            ingress_source_security_group_id = {
                                                  description              = "https-443"
                                                  protocol                 = "tcp"
                                                  from_port                = 443
                                                  to_port                  = 443
                                                  type                     = "ingress"
                                                  source_security_group_id = module.Default_SG.security_group_id
                }
                                            ingress_source_security_group_id = {
                                                  description              = "SSH"
                                                  protocol                 = "tcp"
                                                  from_port                = 22
                                                  to_port                  = 22
                                                  type                     = "ingress"
                                                  source_security_group_id = module.Default_SG.security_group_id
                }
  }

  eks_managed_node_groups = {
    Goku = {
      # Extend node-to-node security group rules
    
      use_custom_launch_template = var.use_custom_launch_template
      disk_size = var.disk_size
      ebs_optimized = var.ebs_optimized
      remote_access = {
                        ec2_ssh_key  = var.key_name
                      }

      min_size     = var.min_size
      max_size     = var.max_size
      desired_size = var.desired_size

      instance_types = var.instance_types

      update_config = {
                        max_unavailable = var.max_unavailable
                      }
    }
  }
  
  tags = {
    "kubernetes.io/cluster/SSJ2" = "owned"
  }
}

---
#Latest version as of 06/19/23
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.13.1"

  cluster_name = var.cluster_name
  cluster_version = var.cluster_version
  enable_irsa = true
  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }

  vpc_id = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets
  cluster_endpoint_public_access = true
  cluster_additional_security_group_ids = [module.SSJ2_cluster_additional_security_group.security_group_id]

  eks_managed_node_groups = {
    Goku = {
      instance_types = var.instance_types
      node_security_group_additional_rules = {
        source_cluster_security_group = true
      }
      min_size = 2
      desired_size = 2
      max_size = 4

      use_custom_launch_template = false
      remote_access = {
        ec2_ssh_key = var.key_name
      }
      disk_size = 20
      ebs_optimized = true
      enable_monitoring = true
      update_config = {
          max_unavailable = 1
        }

    }
  }
  tags = {
    name = "kubernetes.io/cluster/SSJ2"
  }
}
---
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.13.1"

  cluster_name = "SSJ"
  cluster_version = "1.25"
  cluster_endpoint_public_access = true
  enable_irsa = true
  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }

  vpc_id = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  eks_managed_node_groups = {
    Goku = {
      instance_types = ["t2.medium", "t2.medium", "t2.medium", "t2.medium"]
      min_size = 2
      desired_size = 2
      max_size = 4

      use_custom_launch_template = false
      remote_access = {
        ec2_ssh_key = "EKS"
      }
      disk_size = 20
      ebs_optimized = true
      enable_monitoring = true

    }
  }


  tags = {
    name = "kubernetes.io/cluster/SSJ"
  }
}
