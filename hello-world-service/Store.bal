import ballerina.net.http;
import ballerina.observe;

struct Product {
    int id;
    string name;
    float price;
}

struct Order {
    int id;
    float total;
    boolean processed = false;
    Product[] products;
}

@http:configuration {
    port:9090
}
service<http> StoreService {
    resource processOrder (http:Connection conn, http:InRequest req) {
        string parentSpanId = observe:extractSpanContext(req);
        string spanId = observe:startSpan("Wallmart Store", "Place Order", {"span.kind":"server"}, observe:ReferenceType.CHILDOF, parentSpanId);
        map qParams = req.getQueryParams();
        var sId, _ = (string) qParams["orderId"];
        var orderId, _ = <int> sId;
        var o, _ = <json> getOrder(orderId, spanId);
        _ = observe:addLogs(spanId, {event:"store", message:"Order placed for: " + o.toString()});
        http:OutResponse res = {};
        res.setJsonPayload(o);
        _ = conn.respond(res);
        observe:finishSpan(spanId);
    }
}

function getOrder (int orderId, string parentSpanId) (Order) {
    endpoint<http:HttpClient> httpEndpoint {
        create http:HttpClient("http://10.100.7.36:9091", {});
    }
    http:OutRequest req = {};
    http:InResponse resp = {};
    map headers = observe:injectSpanContext(parentSpanId);
    foreach key, v in headers {
        var value, _ = (string)v;
        req.addHeader(key, value);
    }
    resp, _ = httpEndpoint.get("/OrderService/getOrder?orderId=" + orderId, req);
    var order, _ = <Order> resp.getJsonPayload();
    order["processed"] = true;
    return order;
}
