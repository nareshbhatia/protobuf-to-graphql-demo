package main

import (
	"flag"
	"log"
	"net/http"
	"os"

	"github.com/99designs/gqlgen/graphql/handler"
	"github.com/99designs/gqlgen/graphql/playground"
	pbBrand "github.com/nareshbhatia/protobuf-to-graphql-demo/gen/go/brand/v1"
	pbProduct "github.com/nareshbhatia/protobuf-to-graphql-demo/gen/go/product/v1"
	"github.com/nareshbhatia/protobuf-to-graphql-demo/pkg/graph"
	"github.com/nareshbhatia/protobuf-to-graphql-demo/pkg/graph/resolver"
	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials/insecure"
)

const defaultPort = "8080"

var (
	addrProductServer = flag.String("addrProductServer", "localhost:9090", "product server address")
	addrBrandServer   = flag.String("addrBrandServer", "localhost:9091", "brand server address")
)

func main() {
	port := os.Getenv("PORT")
	if port == "" {
		port = defaultPort
	}

	flag.Parse()

	// Set up a connection to the product server.
	connProductServer, err := grpc.Dial(*addrProductServer, grpc.WithTransportCredentials(insecure.NewCredentials()))
	if err != nil {
		log.Fatalf("did not connect: %v", err)
	}
	defer connProductServer.Close()
	productServiceClient := pbProduct.NewProductServiceClient(connProductServer)

	// Set up a connection to the brand server.
	connBrandServer, err := grpc.Dial(*addrBrandServer, grpc.WithTransportCredentials(insecure.NewCredentials()))
	if err != nil {
		log.Fatalf("did not connect: %v", err)
	}
	defer connBrandServer.Close()
	brandServiceClient := pbBrand.NewBrandServiceClient(connBrandServer)

	srv := handler.NewDefaultServer(graph.NewExecutableSchema(graph.Config{Resolvers: resolver.NewResolver(productServiceClient, brandServiceClient)}))

	http.Handle("/", playground.Handler("GraphQL playground", "/query"))
	http.Handle("/query", srv)

	log.Printf("connect to http://localhost:%s/ for GraphQL playground", port)
	log.Fatal(http.ListenAndServe(":"+port, nil))
}
