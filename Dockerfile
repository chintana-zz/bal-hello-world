FROM ballerina/ballerina:0.990.3

USER root

RUN apk add --update \
    curl \
    && rm -rf /var/cache/apk/*

USER ballerina
