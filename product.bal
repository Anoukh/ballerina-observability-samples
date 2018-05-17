import ballerina/http;
import ballerina/sql;
import ballerina/mysql;
import ballerina/observe;

type Product {
    int id;
    string name;
    float price;
};

endpoint http:Listener productServiceEndpoint {
    port:9092
};

@http:ServiceConfig {
    basePath:"/ProductService"
}
service ProductService bind productServiceEndpoint {
    @http:ResourceConfig {
        methods:["GET"],
        path:"/getProduct"
    }
    getProduct(endpoint outboundEP, http:Request req) {
        map qParams = req.getQueryParams();
        string sId = <string> qParams["productId"];
        int id = <int> sId but {error => 0};
        json p = <json> getProductFromDB(id) but {error => {}};
        http:Response res = new;
        res.setJsonPayload(p);
        _ = outboundEP -> respond(res);
    }
}

endpoint mysql:Client productDB {
    host:"localhost",
    port:3306,
    name:"testdb",
    username:"root",
    password:"root",
    poolOptions:{maximumPoolSize:5}
};

function getProductFromDB (int id) returns Product {

    sql:Parameter p1 = {sqlType:sql:TYPE_INTEGER, value:id};
    var temp = productDB -> select("SELECT * FROM PRODUCT WHERE id = ?", Product, p1);
    table<Product> dt = check temp;
    Product product = {};

    foreach x in dt {
        product.id = x.id;
        product.name = x.name;
        product.price = x.price;
    }

    return product;
}
