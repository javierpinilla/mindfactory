
## Costo Calculado con infracost:

Comando: 
```bash
infracost breakdown --path . --project-name mindfactory

```

## Resultado:

```bash

INFO Autodetected 1 Terraform project across 1 root module
INFO Found Terraform project mindfactory at directory . using Terraform var files terraform.tfvars

Project: mindfactory

 Name                                                      Monthly Qty  Unit                    Monthly Cost   
                                                                                                               
 module.eks.aws_eks_cluster.eks                                                                                
 └─ EKS cluster                                                    730  hours                         $73.00   
                                                                                                               
 module.vpc.aws_nat_gateway.vpc_natgw                                                                          
 ├─ NAT gateway                                                    730  hours                         $32.85   
 └─ Data processed                                   Monthly cost depends on usage: $0.045 per GB              
                                                                                                               
 module.eks.aws_eks_node_group.eks_grp                                                                         
 └─ module.eks.aws_launch_template.eks_lt                                                                      
    ├─ Instance usage (Linux/UNIX, spot, t3.medium)                730  hours                         $12.56   
    └─ block_device_mapping[0]                                                                                 
       └─ Storage (general purpose SSD, gp3)                        30  GB                             $2.40   
                                                                                                               
 module.elasticache.aws_elasticache_cluster.redis                                                              
 └─ ElastiCache (on-demand, cache.t3.micro)                        730  hours                         $12.41   
                                                                                                               
 module.s3_bucket.aws_s3_bucket.s3                                                                             
 └─ Standard                                                                                                   
    ├─ Storage                                       Monthly cost depends on usage: $0.023 per GB              
    ├─ PUT, COPY, POST, LIST requests                Monthly cost depends on usage: $0.005 per 1k requests     
    ├─ GET, SELECT, and all other requests           Monthly cost depends on usage: $0.0004 per 1k requests    
    ├─ Select data scanned                           Monthly cost depends on usage: $0.002 per GB              
    └─ Select data returned                          Monthly cost depends on usage: $0.0007 per GB             
                                                                                                               
 OVERALL TOTAL                                                                                      $133.22 

*Usage costs can be estimated by updating Infracost Cloud settings, see docs for other options.

──────────────────────────────────
48 cloud resources were detected:
∙ 5 were estimated
∙ 43 were free

┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┳━━━━━━━━━━━━━━━┳━━━━━━━━━━━━━┳━━━━━━━━━━━━┓
┃ Project                                            ┃ Baseline cost ┃ Usage cost* ┃ Total cost ┃
┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━╋━━━━━━━━━━━━━━━╋━━━━━━━━━━━━━╋━━━━━━━━━━━━┫
┃ mindfactory                                        ┃          $133 ┃           - ┃       $133 ┃
┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┻━━━━━━━━━━━━━━━┻━━━━━━━━━━━━━┻━━━━━━━━━━━━┛

```