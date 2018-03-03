import ballerina.net.http;
import ballerina.tracing;

service<http> helloWorld {

	resource sayHello (http:Connection conn, http:InRequest req) {
		tracing:TracingDepth depth = tracing:getTracingDepth();
		string spanId = startServiceSpan(req, depth, "client", "ballerina-service-1");

		startWorker(req, depth);
		blob x = {};
		http:OutRequest req1 = {};
		req1.setHeader();
		http:OutResponse res = {};
		res.setStringPayload("Hello, World! This is the first ballerina");
		_ = conn.respond(res);
		println("sending...");

		//  callEndpoint();

		sleep(15000);
		_ = finishSpan(spanId, depth, "ballerina-service-1");
	}
}

function callEndpoint() {
  endpoint<http:HttpClient> httpEndpoint {
      create http:HttpClient("http://localhost:9090", {});
  }
  tracing:TracingDepth depth = tracing:getTracingDepth();
  http:InRequest req2 = {};
  string spanId = startServiceSpan(req2, depth, "consumer", "ballerina-service-2");

  println("Calling Next Endpoint....");
  http:OutRequest req = {};

  http:InResponse resp = {};
  req.setHe
  resp, _ = httpEndpoint.get("/helloTwo/sayHello", req);
  println("GET request:");
  println(resp.getJsonPayload());
  _ = finishSpan(spanId, depth, "ballerina-service-2");

}

//service<http> helloTwo {
//  resource sayHello (http:Connection conn, http:InRequest req) {
//      tracing:TracingDepth depth = tracing:getTracingDepth();
//      string spanId = startServiceSpan(req, depth, "consumer", "ballerina-service-2");
//
//      //startWorker(req, depth);
//
//      http:OutResponse res = {};
//      res.setStringPayload("Hello, World! This is the second ballerina");
//      _ = conn.respond(res);
//      println("sending...");
//      //  sleep(15000);
//      _ = finishSpan(spanId, depth, "ballerina-service-2");
//  }
//}

function startWorker(http:InRequest req, tracing:TracingDepth depth) {
	worker w1 {
		string spanId = startSpan(req, depth, "w1", "w1-service");
		sleep(10000);
		println("Hello, World! #1");
		_ = finishSpan(spanId, depth, "w1-service");
	}

	worker w2 {
		string spanId = startSpan(req, depth, "w2", "w2-service");
		sleep(3000);
		startAnotherWorker(req, depth);
		println("Hello, World! #2");
		_ = finishSpan(spanId, depth, "w2-service");
	}
}

function startAnotherWorker(http:InRequest req, tracing:TracingDepth depth) {
	worker w3 {
		string spanId = startSpan(req, depth, "w3", "w3-service");
		sleep(10000);
		println("Hello, World! #3");
		_ = finishSpan(spanId, depth, "w3-service");
	}

	worker w4 {
		string spanId = startSpan(req, depth, "w4", "w4-service");
		sleep(3000);
		println("Hello, World! #4");
		_ = finishSpan(spanId, depth, "w4-service");
	}
}


function startServiceSpan(http:InRequest req, tracing:TracingDepth depth, string spanKind, string serviceName) (string){
	string spanId;
	if(depth != tracing:TracingDepth.NONE){
		map tags = {};
		tags["span.kind"] = spanKind;
		tags["http.url"] = req.rawPath;
		tags["http.method"] = req.method;
		spanId = tracing:buildSpan(req, tags, "Service: helloWorld", true, serviceName);
	}
	return spanId;
}

function startSpan(http:InRequest req, tracing:TracingDepth depth, string spanName, string serviceName) (string){
	string spanId;
	if(depth != tracing:TracingDepth.NONE){
		map tags = {};
		if (serviceName == "w2-service") {
			tags["span.kind"] = "server";
		} else {
			tags["span.kind"] = "client";
		}
		tags["http.url"] = spanName;
		tags["http.method"] = "GET";
		spanId = tracing:buildSpan(req, tags, "Worker : "+ spanName, true, serviceName);
	}
	return spanId;
}

function finishSpan(string spanId, tracing:TracingDepth depth, string serviceName) (boolean){
	if(depth != tracing:TracingDepth.NONE){
		return tracing:finishSpan(spanId, serviceName);
	} else {
		return false;
	}
}
