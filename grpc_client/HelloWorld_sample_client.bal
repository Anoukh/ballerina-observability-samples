import ballerina/io;
import ballerina/grpc;

function main (string... args) {

    endpoint HelloWorldBlockingClient helloWorldBlockingEp {
        url:"http://localhost:9090"
    };

    grpc:Headers headers = new;
    headers.setEntry("Keep-Alive", "300");

    var unionResp = helloWorldBlockingEp->hello("WSO2", headers = headers);

    match unionResp {
        (string, grpc:Headers) payload => {
            string result;
            grpc:Headers resHeaders;
            (result, resHeaders) = payload;
            io:println("Client Got Response : ");
            io:println(result);
            string headerValue = resHeaders.get("Host") ?: "none";
            io:println("Headers: " + headerValue );
        }
        error err => {
            io:println("Error from Connector: " + err.message);
        }
    }

}


