import ballerina/http;
import ballerina/config;
import ballerina/io;
import ballerina/encoding;

http:ClientEndpointConfig clientEPConfig = {
    secureSocket: {            
        keyStore: {
            path: "${ballerina.home}/bre/security/ballerinaKeystore.p12",
            password: "ballerina"
        },
        trustStore: {
            path: "${ballerina.home}/bre/security/ballerinaTruststore.p12",
            password: "ballerina"
        },
        protocol: {
            name: "TLS"
        },
        ciphers: ["TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA"],
        verifyHostname: false
    }
};

public function main() {
        // http:Client clientEP = new("https://host.docker.internal:9443");
        http:Client clientEP = new("https://host.docker.internal:9443", config = clientEPConfig);
        http:Client tokenEP = new("https://host.docker.internal:8243", config = clientEPConfig);

        // Dynamic client registration
        http:Request req = new;
        req.addHeader("Authorization", "Basic YWRtaW46YWRtaW4=");
        req.addHeader("Content-Type", "application/json");
        json regPayload = {
             "callbackUrl": config:getAsString("callbackUrl"),
             "clientName": config:getAsString("clientName"),
             "owner": config:getAsString("owner"),
             "grantType": config:getAsString("grantType"),
             "saasApp": config:getAsString("saasApp")
        };
        req.setPayload(regPayload);

        io:print("Calling dynamic client registration API... ");
        var response = clientEP->post("/client-registration/v0.14/register", req);

        if (response is http:Response) {
                var msg = response.getJsonPayload();
                io:println("OK");

                if (msg is json) {
                        http:Request tokenReq = new;
                        var ks = msg.clientId.toString() + ":" + msg.clientSecret.toString();
                        var authHeader = "Basic " + encoding:encodeBase64(ks.toByteArray("UTF-8"));
                        tokenReq.addHeader("Authorization", authHeader);

                        var payloadStr = "grant_type=password&username=" +
                        config:getAsString("username") + "&password=" +
                        config:getAsString("password") + "&scope=apim:api_create";
                        tokenReq.setPayload(payloadStr);
                        tokenReq.setHeader("content-type", "application/x-www-form-urlencoded");

                        io:print("Getting an access token for creating the API... ");
                        var tokenRes = tokenEP->post("/token", tokenReq);

                        if (tokenRes is http:Response) {
                                var token = tokenRes.getJsonPayload();
                                io:println("OK");
                                if (token is json) {
                                        // Have the access token to create an API

                                        // Read swagger definition
                                        var filePath = "/home/src/bal-hello-world/hello_service.swagger.json";
                                        io:ReadableByteChannel rbc = io:openReadableFile(filePath);
                                        // io:ReadableCharacterChannel rch = new(rbc, "UTF-8");
                                        
                                        int n = 1;
                                        byte[] buf;                                        
                                        var swaggerDef = "";
                                        error readErr;
                                        // Read and append swagger definition to string defined above
                                        while (n > 0) {
                                                (byte[], int)|error r = rbc.read(1000);
                                                if (r is error) {
                                                        panic r;
                                                } else {
                                                        (buf, n) = r;
                                                        swaggerDef += encoding:byteArrayToString(buf);
                                                }                                                
                                        }

                                        http:Request apiReq = new;
                                        apiReq.addHeader("Authorization", "Bearer " + token.access_token.toString());
                                        // Attach swagger definition for "apiDefinition" element below
                                        json apiReqPayload = {
                                                "name": "TestAPI",
                                                "context": "/testapi",
                                                "version": "1.0.0",
                                                "description": null,
                                                "provider": "admin",
                                                "status": "PUBLISHED",
                                                "thumbnailUri": null,
                                                "apiDefinition": swaggerDef,
                                                "wsdlUri": null,
                                                "responseCaching": "Disabled",
                                                "cacheTimeout": 300,
                                                "destinationStatsEnabled": null,
                                                "isDefaultVersion": false,
                                                "type": "HTTP",
                                                "transport": [
                                                        "http",
                                                        "https"
                                                ],
                                                "tags": [],
                                                "tiers": [
                                                        "Unlimited"
                                                ],
                                                "apiLevelPolicy": null,
                                                "authorizationHeader": null,
                                                "apiSecurity": "oauth2",
                                                "maxTps": null,
                                                "visibility": "PUBLIC",
                                                "visibleRoles": [],
                                                "visibleTenants": [],
                                                "endpointConfig": "{\"production_endpoints\":{\"url\":\"http://example.com\",\"config\":null,\"template_not_supported\":false},\"endpoint_type\":\"http\"}",
                                                "endpointSecurity": null,
                                                "gatewayEnvironments": "Production and Sandbox",
                                                "labels": [],
                                                "sequences": [],
                                                "subscriptionAvailability": null,
                                                "subscriptionAvailableTenants": [],
                                                "additionalProperties": {},
                                                "accessControl": "NONE",
                                                "accessControlRoles": [],
                                                "businessInformation": {
                                                        "businessOwner": null,
                                                        "businessOwnerEmail": null,
                                                        "technicalOwner": null,
                                                        "technicalOwnerEmail": null
                                                },
                                                "corsConfiguration": {
                                                        "corsConfigurationEnabled": false,
                                                        "accessControlAllowOrigins": [
                                                        "*"
                                                        ],
                                                        "accessControlAllowCredentials": false,
                                                        "accessControlAllowHeaders": [
                                                        "authorization",
                                                        "Access-Control-Allow-Origin",
                                                        "Content-Type",
                                                        "SOAPAction"
                                                        ],
                                                        "accessControlAllowMethods": [
                                                        "GET",
                                                        "PUT",
                                                        "POST",
                                                        "DELETE",
                                                        "PATCH",
                                                        "OPTIONS"
                                                        ]
                                                }
                                        };
                                        apiReq.setPayload(apiReqPayload);
                                        apiReq.setHeader("content-type", "application/json");

                                        io:print("Creating new API... ");
                                        var apiRes = clientEP->post("/api/am/publisher/v0.14/apis", apiReq);
                                        
                                        if (apiRes is http:Response) {
                                                var resPayload = apiRes.getJsonPayload();
                                                if (resPayload is json) {
                                                        io:println("OK");
                                                } else {
                                                        panic resPayload;
                                                }
                                        } else {
                                                panic apiRes;
                                        }
                                } else {
                                        panic token;
                                }
                        } else {
                        panic tokenRes;
                        }
             } else {
                     panic msg;
             }
     } else {
             panic response;
     }
}
