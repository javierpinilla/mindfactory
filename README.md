# Infraestructura.
## Módulos:
   #### VPC
   #### ElastiCache (Redis)
   #### S3.
   #### EKS.


### Módulo de VPC.

Este modulo contiene el código Terraform para desplegar una VPC con 3 subnets públicas y 3 subnets privadas. También crea un Internet Gateway para la subnets públicas, un Nat Gateway para las subnet privadas.
También crea 3 subnets privadas para Rds o ElastiCache. La route table al NatGW está comentado, si se necesita salida a internet, descomentar el attachment de las rt a las estás subnets de rds o elastiCache.

### Módulo EKS

Con este módulo vamos a crear un cluster eks configurable con un node group y un launch template que define por variables o parámetros, la instancia, la versión, el tamaño del disco, el tipo de ebs. Por defecto usa instancias t3.medium spots, pero esto puede cambiarse en los default de las variables dentro del módulo.
Se usa la ami mas reciente de amazon-eks-node-x86_64.
Se crea un role, y se agregan las políticas para CNI (VPC), y las necesarias para la comunicación entre los nodos, y que estos se puedan unir al control plane.

También se agrega la policy para descargar imagenes desde ECR:
AmazonEC2ContainerRegistryReadOnly

Para el caso de ser necesario usar PVC ebs o efs agregar estás políticas:
AmazonEBSCSIDriverPolicy
AmazonEFSCSIDriverPolicy

### Módulo ElastiCache

Este módulo crea un cluster de ElastiCache (Redis), sin replicación ni autofailover.
El tipo de instancia por defecto es t3.micro que es la más barato junto con la de arm.

### Módulo S3

Acá se crea un bucket simple.  

<br/><br/>


### Arquitectura
La infraestructura implementada sigue una arquitectura de tres capas:

Subredes Públicas : Para recursos que requieren acceso directo a Internet (ej: servidores web).\
Subredes Privadas : Para recursos internos con salidad a internet.\
Subredes Privadas para Servicios de DB: Sin salida a internet. RT Attachments Comentados.

#### Se incluyen:

1 VPC con CIDR configurable.\
3 subredes públicas y 3 privadas (una por Availability Zone).\
Internet Gateway para acceso externo.\
NAT Gateway para salida a internet desde redes privadas. Ojo que tiene costo\ 
Route Tables asociadas a cada tipo de red.\
Network ACLs personalizadas para cada tipo de red.\
Security Group que permite ingreso desde toda la vpc\
DHCP Options default que setea el nombre.
EKS con varios parámetros configurables.
Un cluster Redis ElastiCache.
Bucket s3.

### Requisitos
Terraform v1.0 o superior.\
AWS CLI configurado con credenciales válidas.\
Acceso a una cuenta de AWS con permisos para crear recursos VPC.

### Uso

1. Inicializar el proyecto
```bash
terraform init
```

2. Validar sintaxis
```bash
terraform validate
```

3. Planificar el despliegue
```bash
terraform plan
```

4. Crear infraestructura.
```bash
terraform apply
```

5. Destruir infraestructura (opcional)
```bash
terraform destroy
```



## Estructura del Proyecto

`├── backend.tf`            # Ubicación tfstate\
`├── main.tf`               # Recurso principal que invoca a los cuatro módulos (vpc, eks, elasticache, e3)\
`├── terraform.tfvars`      # Valores de variables.\
`├── variables.tf`          # Declaración de variables.\
`├── outputs.tf`            # Outputs de vpc_id, subnets y sg.\
`└── README.md`             # Documentación actual.\
`── modules`\
`│   ├── eks`\
`│   │   ├── locals.tf`\
`│   │   ├── main.tf`\
`│   │   ├── outputs.tf`\
`│   │   └── variables.tf`\
`│   ├── elasticache`\
`│   │   ├── locals.tf`\
`│   │   ├── main.tf`\
`│   │   ├── output.tf`\
`│   │   └── variables.tf`\
`│   ├── s3`\
`│   │   ├── locals.tf`\
`│   │   ├── main.tf`\
`│   │   ├── outputs.tf`\
`│   │   └── variables.tf`\
`│   └── vpc`\
`│       ├── locals.tf`\
`│       ├── main.tf`\
`│       ├── outputs.tf`\
`│       └── variables.tf`


## Variables Principales


```bash
| Variable                  | Tipo         | Descripción                                      |
|---------------------------|--------------|--------------------------------------------------|
| region                    | string       | Región de AWS                                    |
| vpc_cidr_all              | string       | CIDR para todo tráfico (0.0.0.0/0)               |
| vpc_cidr                  | string       | CIDR de la VPC                                   |
| project_name              | string       | Nombre que se usará para crear los recursos      |
| subnet_public_cidrs       | list(string) | CIDRs para subredes públicas                     |
| subnet_private_cidrs      | list(string) | CIDRs para subredes privadas.                    |
| subnet_private_dbs_cidrs  | list(string) | CIDRs para subredes privadas de RDS O Redis      |
| environment               | string       | Dev o Prod. Usado en los nombres de los recursos |
| common_tags               | map(string)  | Etiquetas comunes para todos los recursos        |
```

## Ejemplo de `terraform.tfvars`

```bash
| Variable                  | Valor Ejemplo                            |
|---------------------------|------------------------------------------|
| region                    | us-east-1                                |
| vpc_cidr_al               | 0.0.0.0/0                                |
| vpc_cidr                  | 10.20.0.0/16                             |
| project_name              | test_project                             |
| environment                | dev                                     |
| subnet_public_cidrs       | ["10.0.1.0/24", "10.0.2.0/24", ...]      |
| subnet_private_cidrs      | ["10.0.21.0/24", "10.0.22.0/24", ...]    |
| subnet_private_rds_cidrs  | ["10.0.41.0/24", "10.0.42.0/24", ...]    |
| common_tags               | { Project = "Poject_name", ... }         |
```

## Seguridad
### Network ACLs:
Subredes públicas permiten tráfico completo (ingreso/salida).\
Subredes privadas permiten tráfico interno y salida a Internet.\
Subredes de DBs (Rds o Redis) sin salida a internet.\
Security Group para Redis puerto default y permisos acceso desde las redes privadas:\
Salida abierta a todas las IPs.


## Configurar donde se va a guardar el `terraform.tfstate` en el archivo `backend.tf`

```hcl
terraform {
  backend "s3" {
    bucket         = "bucket_name_tf_state"
    key            = "terraform/poject_name/vpc/state"
    region         = "us-east-1"
    encrypt        = true
  }

  # Y si queremos el tfstate local.
  #backend "local" {
  #  path = "terraform.tfstate"
  #}
}
```


## Nota Importante
### Este proyecto usa un Nat Gateway que tiene costo:
El costo de un NAT Gateway en AWS es de 0.045 USD por hora y 0.045 USD por GB de datos procesados. También hay un costo por la dirección IPv4 pública si se usa, que es de 0.005 USD por hora por dirección. Estos son valores aproximados.




### [Aquí puedes comparar costos de recursos de `AWS`](https://instances.vantage.sh/)
### [Terraform Docs `AWS` Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)