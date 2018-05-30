import ballerina/io;
import ballerina/http;
import ballerina/runtime;
import ballerina/observe;

type Order {
    int id;
    float total;
    boolean processed = false;
    Product[] products;
};

type Product {
    int id;
    string name;
    float price;
};

function main(string... args) {
    observe:Span span = observe:startSpan("Get order span", userTrace = true);
    io:println(getOrder(1));
    _ = span.finish();
    runtime:sleep(5000); // To allow time for spans to get published
}

function getOrder (int orderId) returns Order {

    endpoint http:Client ep {
        url:"http://localhost:9091"
    };

    http:Request req = new;
    var resp = ep -> get("/OrderService/getOrder?orderId=" + untaint orderId, request = req);
    match resp {
        error err => {
            return {};
        }
        http:Response response => {
            match (response.getJsonPayload()) {
                error payloadError => {
                    return {};
                }
                json res => {
                    Order orders = <Order> res but {error => {}};
                    orders.processed = true;
                    return orders;
                }
            }
        }
    }
}