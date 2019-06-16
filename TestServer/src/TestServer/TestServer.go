package main

import (
	"context"
	"encoding/json"
	"log"
	"net/http"
	"os"

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

	var server = http.Server{Addr: ":8118", Handler: router}

	router.HandleFunc("/nkt/shutdown", func(w http.ResponseWriter, r *http.Request) {
		server.Shutdown(context.Background())
	})

	if err := server.ListenAndServe(); err != nil {
		log.Println(err)
		os.Exit(0)
	}
}

func addHTTPListners(router *mux.Router) {
	router.HandleFunc("/nkt/users/{id}", GetUser).Methods("GET")
	router.HandleFunc("/nkt/users", GetUsers).Methods("GET")
	router.HandleFunc("/nkt/items", GetItemList).Methods("GET")
	router.HandleFunc("/nkt/userAmptyArr", GetEmptyUserArr).Methods("GET")
	router.HandleFunc("/nkt/Get402UserArr", Get402UserArr).Methods("GET")

	router.HandleFunc("nkt/users", AddNewUser).Methods("POST")
	router.HandleFunc("nkt/authWithFormUrl", AuthWithFormURL).Methods("POST")
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
	users = append(users, User{ID: "id0", Lastname: "Fry0", Firstname: "Philip0"})
	users = append(users, User{ID: "id1", Lastname: "Fry1", Firstname: "Philip1"})
	users = append(users, User{ID: "id2", Lastname: "Fry2", Firstname: "Philip2"})
	users = append(users, User{ID: "id3", Lastname: "Fry3", Firstname: "Philip3"})

	json.NewEncoder(w).Encode(users)
	w.Header().Set("Content-Type", "application/json")
}

// GetEmptyUserArr just return an empty array in response body
func GetEmptyUserArr(w http.ResponseWriter, r *http.Request) {

	var users []User

	json.NewEncoder(w).Encode(users)
	w.Header().Set("Content-Type", "application/json")
}

// Get402UserArr just return 204 response code that means "no response"
func Get402UserArr(w http.ResponseWriter, r *http.Request) {
	w.WriteHeader(204)
	return
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

// AuthWithFormURL provides www-form-url-encoded endpoint that await form like:
// secret = "secret"
// type = "type"
// In success case return json:
// { "accessToken": "token", "refreshToken": "token" }
// In failure case return 402 code
func AuthWithFormURL(w http.ResponseWriter, r *http.Request) {
	log.Println(r)
	r.ParseForm()

	var secret = r.FormValue("secret")
	var typeVal = r.FormValue("type")

	log.Println(r)
	log.Println(r.Form)

	if secret == "secret" && typeVal == "type" {
		json.NewEncoder(w).Encode(map[string]string{"accessToken": "token", "refreshToken": "token"})
	}

	w.WriteHeader(http.StatusBadRequest)
}
