module "ebs_csi_irsa_role" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  role_name             = "Goku_ebs-csi"
  attach_ebs_csi_policy = true

  oidc_providers = {
    ex = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
    }
  }

  tags = {
    name = "kubernetes.io/cluster/SSJ"
  }
}

module "efs_csi_irsa_role" {
  source = "../../modules/iam-role-for-service-accounts-eks"

  role_name             = "efs-csi"
  attach_efs_csi_policy = true

  oidc_providers = {
    ex = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:efs-csi-controller-sa"]
    }
  }

  tags = {
    name = "kubernetes.io/cluster/SSJ"
  }
}

module "external_dns_irsa_role" {
  source = "../../modules/iam-role-for-service-accounts-eks"

  role_name                     = "external-dns"
  attach_external_dns_policy    = true
  external_dns_hosted_zone_arns = ["arn:aws:route53:::hostedzone/IClearlyMadeThisUp"]

  oidc_providers = {
    ex = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:external-dns"]
    }
  }

  tags = {
    name = "kubernetes.io/cluster/SSJ"
  }
}

module "cert_manager_irsa_role" {
  source = "../../modules/iam-role-for-service-accounts-eks"

  role_name                     = "cert-manager"
  attach_cert_manager_policy    = true
  cert_manager_hosted_zone_arns = ["arn:aws:route53:::hostedzone/IClearlyMadeThisUp"]

  oidc_providers = {
    ex = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:cert-manager"]
    }
  }

  tags = local.tags
}

module "amazon_managed_service_prometheus_irsa_role" {
  source = "../../modules/iam-role-for-service-accounts-eks"

  role_name                                       = "amazon-managed-service-prometheus"
  attach_amazon_managed_service_prometheus_policy = true

  oidc_providers = {
    ex = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["prometheus:amp-ingest"]
    }
  }

  tags = {
    name = "kubernetes.io/cluster/SSJ"
  }
  }
  

module "load_balancer_controller_irsa_role" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  role_name                              = "load-balancer-controller"
  attach_load_balancer_controller_policy = true

  oidc_providers = {
    ex = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-load-balancer-controller"]
    }
  }

  tags = {
    name = "kubernetes.io/cluster/SSJ"
  }
}

#REF: https://aws-ia.github.io/terraform-aws-eks-blueprints/v4.31.0/add-ons/aws-load-balancer-controller/

module "vpc_cni_ipv4_irsa_role" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  role_name             = "Goku_vpc-cni"
  attach_vpc_cni_policy = true
  vpc_cni_enable_ipv4   = true

  oidc_providers = {
    ex = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-node"]
    }
  }

  tags = {
    name = "kubernetes.io/cluster/SSJ"
  }
}

module "appmesh_controller_irsa_role" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  role_name                        = "Goku_-controller"
  attach_appmesh_controller_policy = true

  oidc_providers = {
    ex = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["appmesh-system:appmesh-controller"]
    }
  }

  tags = {
    name = "kubernetes.io/cluster/SSJ"
  }
}
  
  
  
# DO NOT USE LOAD BALANCER WITH TARGET GROUP BINDING ONLY. IT IS TO ATTACH A LOAD BALANCER TO AN EXISTING ALB AND NLB.
# Ref: https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.1/guide/targetgroupbinding/targetgroupbinding/
  
  #module "load_balancer_controller_targetgroup_binding_only_irsa_role" {
  #source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  #role_name                                                       = "Goku_load-balancer-controller-targetgroup-binding-only"
  #attach_load_balancer_controller_targetgroup_binding_only_policy = true

  #oidc_providers = {
   # ex = {
    #  provider_arn               = module.eks.oidc_provider_arn
     # namespace_service_accounts = ["kube-system:aws-load-balancer-controller"]
   # }
 # }

  #tags = {
   # name = "kubernetes.io/cluster/SSJ"
  #}
#}
