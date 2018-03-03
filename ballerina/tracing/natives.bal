package ballerina.tracing;

import ballerina.net.http;

public enum TracingDepth {
    SERVICE_LEVEL, FUNCTION_LEVEL, NONE
}

@Description { value:"Checks whether tracing is enabled"}
@Return { value:"Returns the depth of the tracing as enum" }
public native function getTracingDepth () (TracingDepth);

@Description { value:"Checks whether tracing is enabled"}
@Param { value:"request: The inbound HTTP request message" }
@Param { value:"tags: The map of tags that needs to be passed into" }
@Param { value:"spanName: The name of the span that's built" }
@Param { value:"isActive: This informs whether to make the span active or not " }
@Param { value:"serviceName: Name of the service or service this span belongs to" }
@Return { value:"String value of the span id that was generated." }
public native function buildSpan (http:InRequest request, map tags, string spanName, boolean isActive, string serviceName) (string);

@Description { value:"Checks whether tracing is enabled"}
@Param { value:"spanId: The ID of the span which is returned during span built time" }
@Param { value:"serviceName: The name of the service " }
@Return { value:"The status of the finish operation" }
public native function finishSpan (string spanId, string serviceName) (boolean);

@Description { value:"Adds span headers when request chaining" }
@Param { value:"serviceName: The name of the service" }
@Return { value:"The headers map" }
public native function getSpanHeaders(string serviceName) (map);

@Description { value:"Get tracing metrics" }
@Param { value:"request: The inbound HTTP request message" }
@Return { value:"The Metrics" }
public native function getMetrics(http:InRequest request) (string);