#!/bin/bash

# Nombre del stack
STACK_NAME="MiNuevoStack"

# Región de AWS
REGION="us-east-1"

# Ruta al archivo de plantilla de CloudFormation
TEMPLATE_FILE="stack_hosted_zone.yml"

# Tags para el stack
TAGS="Name=MiNuevoStack"

# Comando para desplegar la pila
aws cloudformation deploy \
  --template-file $TEMPLATE_FILE \
  --stack-name $STACK_NAME \
  --region $REGION \
  --tags $TAGS \
  --no-fail-on-empty-changeset