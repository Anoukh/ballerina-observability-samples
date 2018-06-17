import ballerina/grpc;
import ballerina/io;

public type HelloWorldBlockingStub object {
    
    public {
        grpc:Client clientEndpoint;
        grpc:Stub stub;
    }

    function initStub (grpc:Client grpcClientEndpoint) {
        grpc:Stub navStub = new;
        navStub.initStub(grpcClientEndpoint, "blocking", DESCRIPTOR_KEY, descriptorMap);
        self.stub = navStub;
    }
    
    function hello (string req, grpc:Headers? headers = ()) returns ((string, grpc:Headers)|error) {
        
        var unionResp = self.stub.blockingExecute("HelloWorld/hello", req, headers = headers);
        match unionResp {
            error payloadError => {
                return payloadError;
            }
            (any, grpc:Headers) payload => {
                any result;
                grpc:Headers resHeaders;
                (result, resHeaders) = payload;
                return (<string>result, resHeaders);
            }
        }
    }
    
};

public type HelloWorldStub object {
    
    public {
        grpc:Client clientEndpoint;
        grpc:Stub stub;
    }

    function initStub (grpc:Client grpcClientEndpoint) {
        grpc:Stub navStub = new;
        navStub.initStub(grpcClientEndpoint, "non-blocking", DESCRIPTOR_KEY, descriptorMap);
        self.stub = navStub;
    }
    
    function hello (string req, typedesc listener, grpc:Headers? headers = ()) returns (error?) {
        return self.stub.nonBlockingExecute("HelloWorld/hello", req, listener, headers = headers);
    }
    
};


public type HelloWorldBlockingClient object {
    
    public {
        grpc:Client client;
        HelloWorldBlockingStub stub;
    }

    public function init (grpc:ClientEndpointConfig config) {
        // initialize client endpoint.
        grpc:Client grpcClient = new;
        grpcClient.init(config);
        self.client = grpcClient;
        // initialize service stub.
        HelloWorldBlockingStub helloWorldStub = new;
        helloWorldStub.initStub(grpcClient);
        self.stub = helloWorldStub;
    }

    public function getCallerActions () returns (HelloWorldBlockingStub) {
        return self.stub;
    }
};

public type HelloWorldClient object {
    
    public {
        grpc:Client client;
        HelloWorldStub stub;
    }

    public function init (grpc:ClientEndpointConfig config) {
        // initialize client endpoint.
        grpc:Client grpcClient = new;
        grpcClient.init(config);
        self.client = grpcClient;
        // initialize service stub.
        HelloWorldStub helloWorldStub = new;
        helloWorldStub.initStub(grpcClient);
        self.stub = helloWorldStub;
    }

    public function getCallerActions () returns (HelloWorldStub) {
        return self.stub;
    }
};



@final string DESCRIPTOR_KEY = "HelloWorld.proto";
map descriptorMap =
{ 
    "HelloWorld.proto":"0A1048656C6C6F576F726C642E70726F746F1A1E676F6F676C652F70726F746F6275662F77726170706572732E70726F746F32510A0A48656C6C6F576F726C6412430A0568656C6C6F121C2E676F6F676C652E70726F746F6275662E537472696E6756616C75651A1C2E676F6F676C652E70726F746F6275662E537472696E6756616C7565620670726F746F33",
  
    "google.protobuf.wrappers.proto":"0A0E77726170706572732E70726F746F120F676F6F676C652E70726F746F62756622230A0B446F75626C6556616C756512140A0576616C7565180120012801520576616C756522220A0A466C6F617456616C756512140A0576616C7565180120012802520576616C756522220A0A496E74363456616C756512140A0576616C7565180120012803520576616C756522230A0B55496E74363456616C756512140A0576616C7565180120012804520576616C756522220A0A496E74333256616C756512140A0576616C7565180120012805520576616C756522230A0B55496E74333256616C756512140A0576616C756518012001280D520576616C756522210A09426F6F6C56616C756512140A0576616C7565180120012808520576616C756522230A0B537472696E6756616C756512140A0576616C7565180120012809520576616C756522220A0A427974657356616C756512140A0576616C756518012001280C520576616C756542570A13636F6D2E676F6F676C652E70726F746F627566420D577261707065727350726F746F50015A057479706573F80101A20203475042AA021E476F6F676C652E50726F746F6275662E57656C6C4B6E6F776E5479706573620670726F746F33"
  
};
