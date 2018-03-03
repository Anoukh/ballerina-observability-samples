import ballerina.net.http;
import ballerina.observe;
import ballerina.io;
import ballerina.runtime;

@http:configuration {basePath:"/customer"}
service<http> helloWorld {

    @http:resourceConfig {
        methods:["GET"],
        path:"/getDetails"
    }
    resource getDetails (http:Connection conn, http:InRequest req) {
        string parentSpanId = observe:extractSpanContext(req);
        string spanId = observe:startSpan("customer", "getDetails", {"span.kind":"server"}, observe:ReferenceType.CHILDOF, parentSpanId);
        callTest(spanId);
        callEndpoint(spanId);
        runtime:sleepCurrentWorker(100);
        callEndpointTwo(spanId);
        callTest(spanId);
        http:OutResponse res = {};
        res.setStringPayload("Customer Details");
        _ = conn.respond(res);
        observe:finishSpan(spanId);
    }
}

function callEndpoint (string parentSpanId) {
    endpoint<http:HttpClient> httpEndpoint {
        create http:HttpClient("http://localhost:9092", {});
    }
    string spanId = observe:startSpan("customer", "clientConnector", {"span.kind":"client"}, observe:ReferenceType.CHILDOF, parentSpanId);
    map headers = observe:injectSpanContext(spanId);
    http:OutRequest req = {};
    http:InResponse resp = {};
    io:println(headers);
    foreach key, v in headers {
        var value, _ = (string)v;
        req.addHeader(key, value);
    }
    _ = observe:addLogs(spanId, {event:"cs", message:"Dispatch call to external service"});
    resp, _ = httpEndpoint.get("/order/details", req);
    _ = observe:addLogs(spanId, {event:"cr", message:"Received response from the external service"});
    io:println(resp.getStringPayload());
    observe:finishSpan(spanId);
}

function callEndpointTwo (string parentSpanId) {
    endpoint<http:HttpClient> httpEndpoint {
        create http:HttpClient("http://localhost:9092", {});
    }
    string spanId = observe:startSpan("customer", "clientConnector", {"span.kind":"client"}, observe:ReferenceType.CHILDOF, parentSpanId);
    map headers = observe:injectSpanContext(spanId);
    http:OutRequest req = {};
    http:InResponse resp = {};
    io:println(headers);
    foreach key, v in headers {
        var value, _ = (string)v;
        req.addHeader(key, value);
    }
    _ = observe:addLogs(spanId, {event:"cs", message:"Dispatch call to external service"});
    resp, _ = httpEndpoint.get("/order/status", req);
    _ = observe:addLogs(spanId, {event:"cr", message:"Received response from the external service"});
    string response = resp.getStringPayload();
    if (response == "Error") {
        _ = observe:addTags(spanId, {error:"true"});
        _ = observe:addLogs(spanId, {"error.kind":"HTTPError", message:"Internel Server Error"});
    }
    observe:finishSpan(spanId);
}

function callTest(string parentSpanId) {
    string spanId = observe:startSpan("customer", "callTest", {}, observe:ReferenceType.CHILDOF, parentSpanId);
    _ = observe:addLogs(spanId, {event:"test function called"});
    _ = observe:addTags(spanId, {component:"user-component"});
    startWorker(spanId);
    runtime:sleepCurrentWorker(300);
    io:println("Done...");
    _ = observe:addLogs(spanId, {event:"finishing test function call"});
    observe:finishSpan(spanId);
}

function startWorker (string parentSpanId) {
    worker w1 {
        map tags = {};
        string spanId = observe:startSpan("customer", "workerOne", tags, observe:ReferenceType.FOLLOWSFROM, parentSpanId);
        _ = observe:addLogs(spanId, {event:"worker one function called"});
        runtime:sleepCurrentWorker(200);
        io:println("Hello, World! #1");
        _ = observe:addLogs(spanId, {event:"worker one function finished"});
        observe:finishSpan(spanId);
    }

    worker w2 {
        map tags = {};
        string spanId = observe:startSpan("customer", "workerTwo", tags, observe:ReferenceType.FOLLOWSFROM, parentSpanId);
        _ = observe:addLogs(spanId, {event:"worker two function called"});
        runtime:sleepCurrentWorker(700);
        io:println("Hello, World! #2");
        _ = observe:addLogs(spanId, {event:"worker two function finished"});
        observe:finishSpan(spanId);
    }
}