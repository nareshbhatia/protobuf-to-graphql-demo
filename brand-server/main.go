package main

import (
	"context"
	"flag"
	"fmt"
	"log"
	"net"

	pb "github.com/nareshbhatia/protobuf-to-graphql-demo/gen/go/brand/v1"
	brand "github.com/nareshbhatia/protobuf-to-graphql-demo/gen/go/models/brand/v1"
	"google.golang.org/grpc"
)

var (
	port = flag.Int("port", 9091, "The brand server port")
)

type server struct {
	pb.UnimplementedBrandServiceServer
}

func (s *server) GetByID(ctx context.Context, in *pb.GetByIDRequest) (*pb.GetByIDResponse, error) {

	brands := map[string]*brand.Brand{
		"1": {
			Id:   "1",
			Name: "Brand 1",
		},
		"2": {
			Id:   "2",
			Name: "Brand 2",
		},
	}

	brand, ok := brands[in.Id]
	if !ok {
		return nil, fmt.Errorf("brand not found")
	}
	return &pb.GetByIDResponse{Brand: brand}, nil
}

func main() {
	flag.Parse()
	lis, err := net.Listen("tcp", fmt.Sprintf(":%d", *port))
	if err != nil {
		log.Fatalf("failed to listen: %v", err)
	}
	s := grpc.NewServer()
	pb.RegisterBrandServiceServer(s, &server{})
	log.Printf("server listening at %v", lis.Addr())
	if err := s.Serve(lis); err != nil {
		log.Fatalf("failed to serve: %v", err)
	}
}
