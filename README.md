# Estructura de carpetas del Proyecto
#### .github/workflow:
  Contiene el workflow para desplegar la app con helm en github actions.

#### app
  Contiene dos carpetas:\
    charts: Para instalar la app por medio de helm.\
    kubectl: Para desplegar los recursos de la app con kubectl, me ayudo para armar el helm.

#### docs
  Contiene el pdf del pedido.

#### gitlab-ci
  Contiene el archivo .gitlab_ci.yml para desplegar la app con helm en gitlab-ci, que es con lo que más experiencia tengo.

#### iac
  Contiene todo el código en terraform para desplegar la infraestructura.\
  Consultar el Readme dentro.


### Docs de ayuda.
Estructura de control en helm para saber si un valor es true o false \
https://helm.sh/docs/chart_template_guide/control_structures \
https://stackoverflow.com/questions/62835605/if-clause-in-helm-chart \
https://pkg.go.dev/text/template

<br/><br/>


## 1.- Crear la infraestructura:

1. Inicializar el proyecto
```bash
cd iac
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

## 2.- Desplegar la aplicación:

```bash
cd app/charts/nginx-mindfactory
helm dependency build .
helm upgrade --install nginx-mindfactory . --namespace mindfactory --create-namespace
```
## 3.- Desplegar la aplicación:

### Consumir la app:


#### Obtener la ip del único nodo
#IP_NODO=$(kubectl get svc nginx-mindfactory-service-nodeport | awk '{print $5}')
IP_NODO=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')

#### Añade al hosts
echo "$IP_NODO nginx-mindfactory.local" >> /etc/hosts

#### Acceder
curl -v http://nginx-mindfactory.local:30080

<br/><br/>
<br/><br/>

# Estructura Completa

├── app\
│   ├── charts\
│   │   └── nginx-mindfactory\
│   │       ├── chart.yml\
│   │       ├── install.txt\
│   │       ├── README.md\
│   │       ├── templates\
│   │       │   ├── configmap.yml\
│   │       │   ├── deployment.yml\
│   │       │   ├── etc_host.yml\
│   │       │   └── service.yml\
│   │       └── values.yml\
│   └── kubectl\
│       ├── configmap.yml\
│       ├── deployment.yml\
│       ├── etc_host.yml\
│       ├── install.txt\
│       ├── service-external.yml\
│       └── service.yml\
├── docs\
│   └── devops_desafio_tecnico.pdf\
├── .github
│   └── workflow
│       └── deploy.yml
├── gitlab-ci\
├── iac\
│   ├── backend.tf\
│   ├── main.tf\
│   ├── modules\
│   │   ├── eks\
│   │   │   ├── locals.tf\
│   │   │   ├── main.tf\
│   │   │   ├── outputs.tf\
│   │   │   └── variables.tf\
│   │   ├── elasticache\
│   │   │   ├── locals.tf\
│   │   │   ├── main.tf\
│   │   │   ├── output.tf\
│   │   │   └── variables.tf\
│   │   ├── s3\
│   │   │   ├── locals.tf\
│   │   │   ├── main.tf\
│   │   │   ├── outputs.tf\
│   │   │   └── variables.tf\
│   │   └── vpc\
│   │       ├── locals.tf\
│   │       ├── main.tf\
│   │       ├── outputs.tf\
│   │       └── variables.tf\
│   ├── providers.tf\
│   ├── provider.tf\
│   ├── README.md\
│   ├── terraform.tfvars\
│   └── variables.tf\
└── README.md\
