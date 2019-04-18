import ballerina/http;

@http:ServiceConfig {
        basePath: "/hello"
}
service hello on new http:Listener(9090) {

    @http:ResourceConfig {
        methods: ["GET"],
        path: "/sayHello"
    }
    resource function sayHello(http:Caller caller, http:Request request) {
        http:Response response = new;
        response.setTextPayload("Hello from " + untaint caller.localAddress.host);
        _ = caller -> respond(response);
    }

    @http:ResourceConfig {
        methods: ["GET"],
        path: "/sayHola"
    }
    resource function sayHola(http:Caller caller, http:Request request) {
        http:Response response = new;
        response.setTextPayload("Hola from " + untaint caller.localAddress.host);
        _ = caller -> respond(response);
    }

    @http:ResourceConfig {
        methods: ["GET"],
        path: "/sayBonjour"
    }
    resource function sayBonjour(http:Caller caller, http:Request request) {
        http:Response response = new;
        response.setTextPayload("Bonjour from " + untaint caller.localAddress.host);
        _ = caller -> respond(response);
    }
}
