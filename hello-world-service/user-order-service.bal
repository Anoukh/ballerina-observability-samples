import ballerina.net.http;
import ballerina.observe;
import ballerina.io;
import ballerina.runtime;
import ballerina.data.sql;

@http:configuration {basePath:"/order", port:9092}
service<http> helloWorld {

    @http:resourceConfig {
        methods:["GET"],
        path:"/details"
    }
    resource getDetails (http:Connection conn, http:InRequest req) {
        io:println("Order service called !");
        io:println(req);
        map tags = {};
        string parentSpanId = observe:extractSpanContext(req);
        tags["span.kind"] = "server";
        string spanId = observe:startSpan("order", "getOrders", tags, observe:ReferenceType.CHILDOF, parentSpanId);
        callTest(spanId);
        runtime:sleepCurrentWorker(3000);
        http:OutResponse res = {};
        res.setStringPayload("Order Details!");
        _ = conn.respond(res);
        observe:finishSpan(spanId);

    }

    @http:resourceConfig {
        methods:["GET"],
        path:"/status"
    }
    resource getStatus (http:Connection conn, http:InRequest req) {
        io:println("Order service called !");
        io:println(req);
        map tags = {};
        string parentSpanId = observe:extractSpanContext(req);
        tags["span.kind"] = "server";
        string spanId = observe:startSpan("order", "getOrderStatus", tags, observe:ReferenceType.CHILDOF, parentSpanId);
        callTest(spanId);
        database(spanId);
        runtime:sleepCurrentWorker(3000);
        http:OutResponse res = {};
        res.setStringPayload("Error");
        _ = conn.respond(res);
        observe:finishSpan(spanId);
    }
}

function callTest (string parentSpanId) {
    string spanId = observe:startSpan("order", "updatOrders", {}, observe:ReferenceType.CHILDOF, parentSpanId);
    _ = observe:addLogs(spanId, {event:"test function called"});
    _ = observe:addTags(spanId, {component:"user-component"});
    //startWorker(spanId);
    runtime:sleepCurrentWorker(300);
    io:println("Done...");
    _ = observe:addLogs(spanId, {event:"finishing test function call"});
    observe:finishSpan(spanId);
}

function database (string parentSpanId) {
    endpoint<sql:ClientConnector> testDB {
        create sql:ClientConnector(sql:DB.MYSQL, "localhost", 3306,
                                   "baldb", "root", "root", {maximumPoolSize:5});
    }
    string spanId = observe:startSpan("order", "updateDatabase", {}, observe:ReferenceType.CHILDOF, parentSpanId);
    try {
        int ret = testDB.update("CREATE TABLE IF NOT EXISTS `baldb`.`test` ( `id` INT NOT NULL AUTO_INCREMENT , `name` VARCHAR(255) NOT NULL , PRIMARY KEY (`id`)) ENGINE = InnoDB;", null);
        int count = testDB.update("INSERT INTO `baldb`.`test` VALUES('Anoukh')", null);
    } catch (error err) {
        _ = observe:addTags(spanId, {error:"true"});
        _ = observe:addLogs(spanId, {"event":"SQL Error", "message":err.message});
    } finally {
        observe:finishSpan(spanId);

    }
}
