package model

type Product struct {
	ID      string `json:"id"`
	Name    string `json:"name"`
	BrandID string `json:"brandId"`
	Brand   *Brand `json:"brand"`
}
