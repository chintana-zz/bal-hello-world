#!/usr/bin/env sh

# Create Swagger definition from service
cd /home/src/bal-hello-world/ 
ballerina swagger export hello_service.bal

# Ballerina Swagger export create an OAS 3.0.1 definition. However, I couldn't get it to work
# with APIM REST API. So converting it to Swagger 2.0
curl -s -X POST \
  --url 'https://www.apimatic.io/api/transform?format=swagger20' \
  -u 'yeyifobiku@dreamcatcher.email:yeyifobiku@dreamcatcher.email'\
  -F 'file=@hello_service.swagger.yaml' > /home/src/bal-hello-world/hello_service.swagger.json

cd /home/src/bal-hello-world/jenkins
ballerina run --config publisher-creds.toml create-api.bal
