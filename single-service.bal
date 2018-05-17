import ballerina/http;
import ballerina/observe;
import ballerina/runtime;
import ballerina/io;

endpoint http:Listener storeServiceEndpoint {
    port:9090
};

@http:ServiceConfig {
    basePath:"/HelloWorld"
}
service HelloWorld bind storeServiceEndpoint {
    @http:ResourceConfig {
        methods:["GET"],
        path:"/sayHello"
    }
    sayHello(endpoint outboundEP, http:Request req) {

        observe:Span span = observe:startSpan("Hello Service", "Hello Span");
        http:Response res = new;
        res.setPayload("Hello World");
        _ = outboundEP -> respond(res);

        _ = span.finish();
        var e = span.addTag("TagKey", "TagValue");
        match e {
            error er => io:println("Error " + er.message);
            () => io:println("Tag Added");
        }
    }
}