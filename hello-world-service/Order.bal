import ballerina.net.http;
import ballerina.collections;
import ballerina.data.sql;
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

struct OrderEntry {
    int orderId;
    int productId;
}

@http:configuration {
    port:9091
}
service<http> OrderService {
    resource getOrder (http:Connection conn, http:InRequest req) {
        string parentSpanId = observe:extractSpanContext(req);
        string spanId = observe:startSpan("Wallmart Ordering", "Creating Order", {"span.kind":"server"}, observe:ReferenceType.CHILDOF, parentSpanId);
        map qParams = req.getQueryParams();
        var sId, _ = (string) qParams["orderId"];
        var orderId, _ = <int> sId;
        Order order = getProductsForOrder(orderId, spanId);
        var o, _ = <json> order;
        _ = observe:addLogs(spanId, {event:"order", message:"Order placed with total " + order.total});
        http:OutResponse res = {};
        res.setJsonPayload(o);
        observe:finishSpan(spanId);
        _ = conn.respond(res);
    }
}

function getProductsForOrder (int id, string parentSpanId) (Order){
    endpoint<http:HttpClient> httpEndpoint {
        create http:HttpClient("http://localhost:9092", {});
    }

    endpoint<sql:ClientConnector> orderDB {
        create sql:ClientConnector(sql:DB.MYSQL, "localhost", 3306,
                                   "testdb", "root", "root", {maximumPoolSize:5});
    }
    Product[] vProducts = [];
    collections:Vector products = {vec:vProducts};
    float total = 0f;

    sql:Parameter[] params = [];
    sql:Parameter orderId = {sqlType:sql:Type.INTEGER, value:id};
    params = [orderId];
    table<OrderEntry> dt = orderDB.select("SELECT * FROM ORDERS WHERE orderId = ?", params, typeof OrderEntry);
    foreach p in dt {
        http:OutRequest req = {};
        http:InResponse resp = {};
        map headers = observe:injectSpanContext(parentSpanId);
        foreach key, v in headers {
            var value, _ = (string)v;
            req.addHeader(key, value);
        }
        string url = "/ProductService/getProduct?productId=" + p.productId;
        resp, _ = httpEndpoint.get(url, req);
        var product, _ = <Product> resp.getJsonPayload();
        products.add(product);
        total = total + product["price"];
    }

    Order order = {};
    order["id"] = id;
    order["total"] = total;
    order["products"] = vProducts;

    orderDB.close();

    return order;
}
