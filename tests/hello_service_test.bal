import ballerina/test;
import ballerina/http;
import ballerina/io;
http:Client clientEP = new("http://localhost:9090/hello");

@test:Config
function testResourceSayHello() {
        http:Request req = new;
        var resp = clientEP->get("/sayHello");
        if (resp is http:Response) {
                test:assertEquals(resp.statusCode, 200, msg = "Error response");
        } else {
                test:assertFail(msg = "Test Failed!");
        }
}

@test:Config
function testResourceSayHola() {
        http:Request req = new;
        var resp = clientEP->get("/sayHola");
        if (resp is http:Response) {
                test:assertEquals(resp.statusCode, 200, msg = "Error response");
        } else {
                test:assertFail(msg = "Test Failed!");
        }
}

@test:Config
function testResourceSayBonjour() {
        http:Request req = new;
        var resp = clientEP->get("/sayBonjour");
        if (resp is http:Response) {
                test:assertEquals(resp.statusCode, 200, msg = "Error response");
        } else {
                test:assertFail(msg = "Test Failed!");
        }
}