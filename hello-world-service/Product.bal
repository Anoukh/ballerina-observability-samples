import ballerina.net.http;
import ballerina.data.sql;
import ballerina.observe;

struct Product {
    int id;
    string name;
    float price;
}

@http:configuration {
    port:9092
}
service<http> ProductService {
    resource getProduct (http:Connection conn, http:InRequest req) {
        string parentSpanId = observe:extractSpanContext(req);
        string spanId = observe:startSpan("Wallmart Product", "Placing Order", {"span.kind":"server"}, observe:ReferenceType.CHILDOF, parentSpanId);
        map qParams = req.getQueryParams();
        var sId, _ = (string) qParams["productId"];
        var id, _ = <int> sId;
        var p, _ = <json> getProductFromDB(id, spanId);
        http:OutResponse res = {};
        res.setJsonPayload(p);
        observe:finishSpan(spanId);
        _ = conn.respond(res);
    }
}

function getProductFromDB (int id, string parentSpanId) (Product) {

    endpoint<sql:ClientConnector> productDB {
        create sql:ClientConnector(sql:DB.MYSQL, "localhost", 3306,
                                   "testdb", "root", "root", {maximumPoolSize:5});
    }
    sql:Parameter[] params = [];
    sql:Parameter productId = {sqlType:sql:Type.INTEGER, value:id};
    params = [productId];
    table<Product> dt = productDB.select("SELECT * FROM PRODUCT WHERE id = ?", params, typeof Product);
    Product product = {};

    foreach x in dt {
        product["id"] = x.id;
        product["name"] = x.name;
        product["price"] = x.price;
        _ =observe:addLogs(parentSpanId, {event:"product", message:"product ordered: " + x.name});
    }

    productDB.close();
    return product;
}
