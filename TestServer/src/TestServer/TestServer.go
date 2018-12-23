package main

import (
	"encoding/json"
	"log"
	"net/http"

	"github.com/gorilla/mux"
)

// User stub model
type User struct {
	ID        string `json:"id,omitempty"`
	Firstname string `json:"firstname,omitempty"`
	Lastname  string `json:"lastname,omitempty"`
}

func main() {
	router := mux.NewRouter()
	addHTTPListners(router)
	log.Fatal(http.ListenAndServe(":8811", router))
}

func addHTTPListners(router *mux.Router) {
	router.HandleFunc("/users/{id}", GetUser).Methods("GET")
}

// GetUser description
// 500 error with message "Something went wrong" id = 0
// 403 error id = 1
// 402 error id = 2
// 200 success id = any other
// Returns user with recived Id
func GetUser(w http.ResponseWriter, r *http.Request) {
	params := mux.Vars(r)
	switch params["id"] {
	case "0":
		http.Error(w, "Something went wrong", 500)
	case "1":
		http.Error(w, "", 403)
	case "2":
		http.Error(w, "", 402)
	default:
		json.NewEncoder(w).Encode(User{ID: params["id"], Firstname: "John", Lastname: "Jackson"})
	}
}
