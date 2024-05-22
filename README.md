# Protobuf to GraphQL Demo

## Getting started

1. Make sure you have Go and Buf installed.
2. In shell 1, run `go run ./product-server/main.go` to start the product server.
3. In shell 2, run `go run ./brand-server/main.go` to start the brand server.
4. In shell 3, run `go run ./client/main.go` to start the client.

The client should now print a list of products along with their brands.

### Notes

1. Product server runs on port 9090.
2. Brand server runs on port 9091.

## Running proto-gen

```shell
make proto-lint
make proto-gen
```
