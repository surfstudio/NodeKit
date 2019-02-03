package main

import (
	"context"
	"encoding/json"
	"log"
	"net/http"

	"strconv"

	"github.com/gorilla/mux"
)

// User stub model
type User struct {
	ID        string `json:"id,omitempty"`
	Firstname string `json:"firstName,omitempty"`
	Lastname  string `json:"lastName,omitempty"`
}

func main() {
	router := mux.NewRouter()
	addHTTPListners(router)

	var server = http.Server{Addr: ":8811", Handler: router}

	router.HandleFunc("/shutdown", func(w http.ResponseWriter, r *http.Request) {
		server.Shutdown(context.Background())
	})

	if err := server.ListenAndServe(); err != nil {
		log.Fatal(err)
	}
}

func addHTTPListners(router *mux.Router) {
	router.HandleFunc("/users/{id}", GetUser).Methods("GET")
	router.HandleFunc("/users", GetUsers).Methods("GET")
	router.HandleFunc("/items", GetItemList).Methods("GET")
	router.HandleFunc("/users", AddNewUser).Methods("POST")
}

// GetUser description
// 500 error with message "Something went wrong" id = 0
// 403 error id = 1
// 400 error id = 2
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
		http.Error(w, "", 400)
	default:
		json.NewEncoder(w).Encode(User{ID: params["id"], Firstname: "John", Lastname: "Jackson"})
	}
	w.Header().Set("Content-Type", "application/json")
}

// GetUsers return 4 users
func GetUsers(w http.ResponseWriter, r *http.Request) {
	var users []User
	users = append(users, User{ID: "olololo", Lastname: "Fry", Firstname: "Philip"})
	users = append(users, User{ID: "olololo1", Lastname: "Fry1", Firstname: "Philip1"})
	users = append(users, User{ID: "olololo2", Lastname: "Fry2", Firstname: "Philip2"})
	users = append(users, User{ID: "olololo3", Lastname: "Fry3", Firstname: "Philip3"})

	json.NewEncoder(w).Encode(users)
	w.Header().Set("Content-Type", "application/json")
}

// GetItemList return item with offset paging
// If we cant convert request count field to int - method throws http error 400
// If count == 0 or 5 return empty list (it means that paging ends)
// If count == 3 return 500 error
func GetItemList(w http.ResponseWriter, r *http.Request) {
	params, ok := r.URL.Query()["count"]

	if !ok || len(params[0]) < 1 {
		http.Error(w, "Bad count", 400)
		return
	}

	count, error := strconv.Atoi(params[0])

	if error != nil {
		http.Error(w, "Bad count", 402)
		return
	}

	if count == 3 {
		http.Error(w, "Something went wrong", 500)
		return
	}

	if count == 0 || count == -5 {
		w.WriteHeader(204)
		return
	}

	var users []User

	for index := 0; index < count; index++ {
		stringIndex := strconv.Itoa(index)
		users = append(users, User{ID: stringIndex, Lastname: stringIndex, Firstname: stringIndex})
	}
	json.NewEncoder(w).Encode(users)
}

// AddNewUser awaits user with specific id
// id == 1 response 409 with message "Already exist"
// id == Any other response 201
// body not exist = response 400
func AddNewUser(w http.ResponseWriter, r *http.Request) {
	var user User
	if json.NewDecoder(r.Body).Decode(&user) != nil {
		w.WriteHeader(400)
		return
	}

	switch user.ID {
	case "409":
		http.Error(w, "Already exist", 409)
	default:
		w.WriteHeader(201)
	}
}
