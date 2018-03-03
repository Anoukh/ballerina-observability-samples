import ballerina.net.http;
import ballerina.io;
import ballerina.runtime;

@http:configuration {basePath:"/orders", port:9096}
service<http> orders {

    @http:resourceConfig {
        methods:["GET"],
        path:"/"
    }
    resource get (http:Connection conn, http:InRequest req) {
        startWorker();
        http:OutResponse res = {};
        res.setStringPayload("Hello, World! This is the second ballerina");
        _ = conn.respond(res);
    }
}

function startWorker () {
    worker w1 {
        runtime:sleepCurrentWorker(1000);
        io:println("Hello, World! #1");
    }

    worker w2 {
        runtime:sleepCurrentWorker(1000);
        io:println("Hello, World! #2");
    }
}
