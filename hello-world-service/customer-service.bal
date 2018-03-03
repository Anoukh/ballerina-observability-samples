import ballerina.net.http;
import ballerina.io;
import ballerina.runtime;

@http:configuration {basePath:"/customer", port:9095}
service<http> customer {

    @http:resourceConfig {
        methods:["GET"],
        path:"/getDetails"
    }
    resource getDetails (http:Connection conn, http:InRequest req) {
        callEndpoint();
        runtime:sleepCurrentWorker(1000);
        callEndpoint();
        runtime:sleepCurrentWorker(1000);
        callEndpoint();
        http:OutResponse res = {};
        res.setStringPayload("Hello, World! This is the first ballerina");
        _ = conn.respond(res);
        io:println("Say Hello Print");
    }
}

function callEndpoint () {
    endpoint<http:HttpClient> httpEndpoint {
        create http:HttpClient("http://localhost:9096", {});
    }
    http:InRequest req2 = {};

    io:println("Calling Next Endpoint....");

    http:OutRequest req = {};
    http:InResponse resp = {};
    resp, _ = httpEndpoint.get("/orders", req);
    io:println("GET request:");
    io:println(resp.getStringPayload());

}

