import ballerina/http;
import ballerina/mime;
import ballerina/sql;
import ballerina/mysql;
import ballerina/observe;

endpoint http:Listener orderServiceEndpoint {
    port:9091
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

type OrderEntry {
    int orderId;
    int productId;
};

@http:ServiceConfig {
    basePath:"/OrderService"
}
service OrderService bind orderServiceEndpoint {
    @http:ResourceConfig {
        methods:["GET"],
        path:"/getOrder"
    }
    getOrder(endpoint outboundEP, http:Request req) {
        map qParams = req.getQueryParams();
        string sId = <string> qParams["orderId"];
        int orderId = <int> sId but {error => 0};
        Order orders = getProductsForOrder(orderId);
        json o = <json> orders but {error => {}};
        http:Response res = new;
        res.setJsonPayload(o);
        _ = outboundEP -> respond(res);
    }
}

endpoint mysql:Client testDB {
    host:"localhost",
    port:3306,
    name:"testdb",
    username:"root",
    password:"root",
    poolOptions:{maximumPoolSize:5}
};

function getProductsForOrder (int id) returns Order {

    endpoint http:Client ep {
        url:"http://localhost:9092"
    };

    float total = 0f;
    Product[] vProducts = [];
    int count = 0;
    sql:Parameter p1 = {sqlType:sql:TYPE_INTEGER, value:id};
    var temp = testDB -> select("SELECT * FROM ORDERS WHERE orderId = ?", OrderEntry, p1);
    table<OrderEntry> dt = check temp;
    observe:Span span = observe:startSpan("OrderService", "Calling Product Service");
    foreach p in dt {
        http:Request req = new;
        var resp = ep -> get("/ProductService/getProduct?productId=" + untaint p.productId);
        match resp {
            error err => return {};
            http:Response response => {
                match (response.getJsonPayload()) {
                    error payloadError => return {};
                    json res => {
                        Product product = <Product> res but {error => {}};
                        vProducts[count] = product;
                        count = count + 1;
                        total = total + product.price;
                    }
                }
            }
        }
    }
    _ = span.addTag("Orders", "Successful");
    _ = span.finish();
    Order orders = {};
    orders.id = id;
    orders.total = total;
    orders.products = vProducts;

    return orders;
}
