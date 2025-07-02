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
Estructura de control en helm para saber si un valor es true o false
https://helm.sh/docs/chart_template_guide/control_structures/
https://stackoverflow.com/questions/62835605/if-clause-in-helm-chart
https://pkg.go.dev/text/template

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
