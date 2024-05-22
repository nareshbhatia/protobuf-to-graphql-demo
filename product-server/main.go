package main

import (
	"context"
	"flag"
	"fmt"
	"log"
	"net"

	product "github.com/nareshbhatia/protobuf-to-graphql-demo/gen/go/models/product/v1"
	pb "github.com/nareshbhatia/protobuf-to-graphql-demo/gen/go/product/v1"
	"google.golang.org/grpc"
)

var (
	port = flag.Int("port", 9090, "The product server port")
)

type server struct {
	pb.UnimplementedProductServiceServer
}

func (s *server) ListProducts(ctx context.Context, in *pb.ListProductsRequest) (*pb.ListProductsResponse, error) {

	products := []*product.Product{
		&product.Product{
			Id:      "1",
			Name:    "Product 1",
			BrandId: "1",
		},
		&product.Product{
			Id:      "2",
			Name:    "Product 2",
			BrandId: "2",
		},
	}
	return &pb.ListProductsResponse{Products: products}, nil
}

func main() {
	flag.Parse()
	lis, err := net.Listen("tcp", fmt.Sprintf(":%d", *port))
	if err != nil {
		log.Fatalf("failed to listen: %v", err)
	}
	s := grpc.NewServer()
	pb.RegisterProductServiceServer(s, &server{})
	log.Printf("server listening at %v", lis.Addr())
	if err := s.Serve(lis); err != nil {
		log.Fatalf("failed to serve: %v", err)
	}
}
