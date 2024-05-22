package main

import (
	"context"
	"flag"
	"fmt"
	"log"
	"time"

	pbBrand "github.com/nareshbhatia/protobuf-to-graphql-demo/gen/go/brand/v1"
	pbProduct "github.com/nareshbhatia/protobuf-to-graphql-demo/gen/go/product/v1"
	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials/insecure"
)

var (
	addrProductServer = flag.String("addrProductServer", "localhost:9090", "product server address")
	addrBrandServer   = flag.String("addrBrandServer", "localhost:9091", "brand server address")
)

func main() {
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

	// Contact the server and print out its response.
	ctx, cancel := context.WithTimeout(context.Background(), time.Second)
	defer cancel()

	r, err := productServiceClient.ListProducts(ctx, &pbProduct.ListProductsRequest{})
	if err != nil {
		log.Fatalf("could not list products: %v", err)
	}

	// for each product, get the brand name
	for _, product := range r.GetProducts() {
		brandResponse, err := brandServiceClient.GetByID(ctx, &pbBrand.GetByIDRequest{Id: product.BrandId})
		if err != nil {
			log.Fatalf("could not get brand: %v", err)
		}
		fmt.Printf("%s, %s\n", product.Name, brandResponse.GetBrand().Name)
	}
}
