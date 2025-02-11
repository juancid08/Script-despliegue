#!/bin/bash

# Nombre del stack
STACK_NAME="MiNuevoStack"

# Región de AWS
REGION="us-east-1"

# Comando para eliminar la pila
aws cloudformation delete-stack \
  --stack-name $STACK_NAME \
  --region $REGION \