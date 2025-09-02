package main

import (
	"context"
	"database/sql"
	"fmt"
	"log"
	"os"

	"github.com/gin-gonic/gin"
	"github.com/jackc/pgx/v5"
	_ "github.com/lib/pq"
)

/*	.________________________________________________________________________________________________________________________________#____________#________________#_________.
  /|                                                                                                                                ###          ###             ###         |
 / |                  ~~~~~~~~~~~~~~~~~Backend Tenezus Project[0]~~~~~~~~~~~~~~~~~                                                 #####        #####          #####         |
|  |                     :::::::::::::::::::Author==Poseidon:::::::::::::::::::                                                   #######      #######       #######         |
|  |    .___________.                                                           #                                                #########    #########    #########         |
|  |   /|  ._______. \                                                         ###                                               ########### ########### ###########         |
|  |  | |  |		| |                                                       #####            ___                                #################################          |
|  |  | |  |        |.|                  ._____________    .__________._.    #######          |  |\                   ___                    ###########                     |
|  |  | |   ._______/ |   ________.     /  ._________/_/  /    ____    \ \   |___|_|          |  | |    ________.    |   \ ________           #########                      |
|  |  | |  |_________/   / /.____  \   '  / /            |    |    |    | |  .___._           |  | |   / /.____  \   |   |/        \           #######                       |
|  |  | |  |	        | | |    |  |  |_|_|__________   |  __|____|    |_|  |   | |          |  | |  | | |    |  |  |    ______    |           #####                        |
|  |  | |  |		    | | |    |  |  |  __________\ \  | | |_________/_/   |   | |   _______|  | |  | | |    |  |  |   /      |   |            ###                         |
|  |  | |  |		    | | |    |  |             | | |  | | |               |   | |  |  ____    | |  | | |    |  |  |   |      |   |            ###                         |
|  |  | |  |            | | |____|  |   /_________|_| |. |  \_\________.__.  |   | |  | |____|   | |  | | |____|  |  |   |      |   |            ###                         |
|  |  | |__|.            \_\_______/   /._________ /  /   \____________/_/   |___|_|  |__________| |   \_\_______/   |___|      |___|            ###                         |
|  |  |/___/                                                                           \_________.\|                                             ###                         |
|  |_____________________________________________________________________________________________________________________________________________###_________________________.
| /                                                                                                                                              ###                         /
|/_______________________________________________________________________________________________________________________________________________###________________________/
*/

//the type for the quote in the array before the transformation in json
type Quotes struct {
	Id         uint64 `json: "id"`
	Content    string `json: "content"`
	Author     string `json: "author"`
	Created_at string `json: "created_at"`
	Like       uint64 `json: "like"`
	User_photo string `json: "user_photo"`
}

type Poster struct {
	Content    string `json: "content"`
	Author     string `json: "author"`
	User_photo string `json: "user_photo"`
}

// the array to store all the quotes
var quotes []Quotes

//postgresql://postgres:[YOUR-PASSWORD]@db.qxfmtqrnjdfiptrfpzsq.supabase.co:5432/postgres

func getAllQuotes(c *gin.Context) {
	//connection to the postgres database on supabase
	var conn *pgx.Conn
	conn, err := pgx.Connect(context.Background(), "postgresql://postgres.qxfmtqrnjdfiptrfpzsq:jYourPassword@aws-0-eu-north-1.pooler.supabase.com:6543/postgres")
	if err != nil {
		log.Fatalf("failed to connect to the database: %v", err)
	}
	//defer conn.Close(context.Background())

	//select all quotes [id, content, author, created_at, like]
	rows, err := conn.Query(context.Background(), `select id, content, author, created_at,"like", user_photo from quote `, pgx.QueryExecModeSimpleProtocol)
	if err != nil {
		log.Fatal(err)
	}
	defer conn.Close(context.Background())

	var q Quotes

	for rows.Next() {

		err := rows.Scan(&q.Id, &q.Content, &q.Author, &q.Created_at, &q.Like, &q.User_photo)
		if err != nil {
			log.Fatal(err)
		}
		fmt.Println(q.Id, "'"+q.Content+"'", q.Author, q.Created_at, q.Like, q.User_photo)

		//quotes := quotes{Id: id, Content: content, Author: author, Created_at: created_at, Like: like}
		quotes = append(quotes, q)
	}

	c.IndentedJSON(200, quotes) //servir les quotes
	quotes = quotes[:0]         //vider le slice
}

func postQuote(c *gin.Context) {
	//desocer le Json
	var poster Poster
	err := c.ShouldBindJSON(&poster)
	if err != nil {
		log.Fatal(err)
	}

	//connexion a la base de donnees:
	//var conn *pgx.Conn
	conn, err := sql.Open("postgres", "host=aws-0-eu-north-1.pooler.supabase.com port=6543 user=postgres.qxfmtqrnjdfiptrfpzsq password=YourPassWord dbname=postgres sslmode=disable")
	if err != nil {
		log.Fatal(err)
	}
	defer conn.Close()

	err = conn.Ping()
	if err != nil {
		log.Fatal(err)
	}

	//conn, _ := pgxpool.New(context.Background(),"postgresql://postgres.qxfmtqrnjdfiptrfpzsq:YourPassWord@aws-0-eu-north-1.pooler.supabase.com:6543/postgres")
	//defer conn.Close()

	sql := `insert into quote(content, author, user_photo) values($1, $2, $3)`

	_, _ = conn.Exec(sql, poster.Content, poster.Author, poster.User_photo)

	// if(err != nil){
	// 	log.Println(err)
	// }
	c.Status(201)
}

func myQuote(c *gin.Context) {
	author := c.Query("author")

	//connexion a la base de donnee
	conn, err := sql.Open("postgres", "host=aws-0-eu-north-1.pooler.supabase.com port=6543 user=postgres.qxfmtqrnjdfiptrfpzsq password=YourPassWord dbname=postgres sslmode=disable")
	if err != nil {
		log.Fatal(err)
	}
	defer conn.Close()

	//pinguer la base de donnee pour voir si elle repond afin de conclure qu'une connexion est bien etablies avec succes
	err = conn.Ping()
	if err != nil {
		log.Fatal(err)
	}
	defer conn.Close()

	//preparation de la requete sql
	sql := `select * from quote where author = ($1)`

	//execution de la requete
	rows, _ := conn.Query(sql, author)
	//if err != nil{log.Fatal(err)}
	defer rows.Close()

	var q Quotes
	for rows.Next() {
		err := rows.Scan(&q.Id, &q.Content, &q.Author, &q.Created_at, &q.Like, &q.User_photo)
		if err != nil {
			log.Fatal(err)
		}
		quotes = append(quotes, q)
	}

	c.IndentedJSON(200, quotes)
	quotes = quotes[:0]
}

func fiveBest(c *gin.Context) {
	//connection to the postgres database on supabase
	var conn *pgx.Conn
	conn, err := pgx.Connect(context.Background(), "postgresql://postgres.qxfmtqrnjdfiptrfpzsq:YourPassWord@aws-0-eu-north-1.pooler.supabase.com:6543/postgres")
	if err != nil {
		log.Fatalf("failed to connect to the database: %v", err)
	}

	//select all quotes [id, content, author, created_at, like]
	rows, err := conn.Query(context.Background(), `select id, content, author, created_at,"like", user_photo from quote order by "like" desc limit 5 `, pgx.QueryExecModeSimpleProtocol)
	if err != nil {
		log.Fatal(err)
	}
	defer conn.Close(context.Background())

	var q Quotes
	for rows.Next() {

		err := rows.Scan(&q.Id, &q.Content, &q.Author, &q.Created_at, &q.Like, &q.User_photo)
		if err != nil {
			log.Fatal(err)
		}
		fmt.Println(q.Id, "'"+q.Content+"'", q.Author, q.Created_at, q.Like, q.User_photo)

		//quotes := quotes{Id: id, Content: content, Author: author, Created_at: created_at, Like: like}
		quotes = append(quotes, q)
	}

	c.IndentedJSON(200, quotes) //servir les quotes
	quotes = quotes[:0]         //vider le slice
}

func main() {
	//initialize a router
	router := gin.Default()

	//endpoints
	router.GET("/quotes", getAllQuotes)  //to handle all quote
	router.POST("/postQuote", postQuote) //to add a quote
	router.GET("/myquote", myQuote)      // the historique of user quote
	router.GET("/5best", fiveBest)       //the five most like quote on qface

	//serve on port 8080
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}
	if err := router.Run(":" + port); err != nil {
		log.Panicf("error: %s", err)
	}
}
