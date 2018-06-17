import ballerina/io;
import ballerina/grpc;
import ballerina/observe;

endpoint grpc:Listener ep {
    host:"localhost",
    port:9090
};

service HelloWorld bind ep {
    hello(endpoint caller, string name, grpc:Headers headers) {
        int spanId = check observe:startSpan("Track Call");
        io:println("name: " + name);
        string message = "Hello " + name;
        io:println(headers.get("Keep-Alive"));

        grpc:Headers resHeader = new;
        resHeader.setEntry("Host", "ballerina.io");

        error? err = caller->send(message, headers = resHeader);
        io:println(err.message but { () => "Server send response : " + message });

        _ = caller->complete();

        _ = observe:finishSpan(spanId);
    }
}