import ballerina/http;
import ballerina/mime;
import ballerina/io;
import ballerina/observe;

endpoint http:Listener storeServiceEndpoint {
    port:9090
};

type Product {
    int id;
    string name;
    float price;
};

type Order {
    int id;
    float total;
    boolean processed = false;
    Product[] products;
};

@http:ServiceConfig {
    basePath:"/StoreService"
}
service StoreService bind storeServiceEndpoint {
    @http:ResourceConfig {
        methods:["GET"],
        path:"/processOrder"
    }
    processOrder(endpoint outboundEP, http:Request req) {
        map qParams = req.getQueryParams();
        string sId = <string> qParams["orderId"];
        int orderId = (<int> sId) but {error => 0};
        observe:Span span = observe:startSpan("StoreService", "Get order span");
        json o = <json> getOrder(orderId) but {error => {}};
        http:Response res = new;
        res.setJsonPayload(o);
        _ = outboundEP -> respond(res);
        _ = span.finish();
    }
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