package resolver

//go:generate go run github.com/99designs/gqlgen generate

// This file will not be regenerated automatically.
//
// It serves as dependency injection for your app, add any dependencies you require here.

import (
	brandpb "github.com/nareshbhatia/protobuf-to-graphql-demo/gen/go/brand/v1"
	productpb "github.com/nareshbhatia/protobuf-to-graphql-demo/gen/go/product/v1"
)

type Resolver struct {
	productServiceClient productpb.ProductServiceClient
	brandServiceClient   brandpb.BrandServiceClient
}

func NewResolver(productServiceClient productpb.ProductServiceClient, brandServiceClient brandpb.BrandServiceClient) *Resolver {
	return &Resolver{productServiceClient: productServiceClient, brandServiceClient: brandServiceClient}
}
