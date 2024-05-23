# Protobuf to GraphQL Demo

## Getting started

1. Make sure you have Go and Buf installed.
2. In shell 1, run `go run ./product-server/main.go` to start the product server.
3. In shell 2, run `go run ./brand-server/main.go` to start the brand server.
4. In shell 3, run `go run ./client/main.go` to run the grpc client.
   It should print a list of products along with their brands.
5. In shell 4, run `go run server.go` to start the graphql gateway.

### Notes

1. Product server runs on port 9090.
2. Brand server runs on port 9091.

## Running proto-gen

```shell
make proto-lint
make proto-gen
```

## Running gqlgen

```shell
go run github.com/99designs/gqlgen generate
```
